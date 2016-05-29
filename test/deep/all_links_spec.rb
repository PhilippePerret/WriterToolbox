# encoding: UTF-8
=begin

  Ce module vérifie tous les liens du site et signale les liens
  morts.

  Il parcourt toutes les pages en relevant les liens qui conduisent
  à une erreur 404 ou une autre erreur dans la page.

  Il fait un rapport final avec tous les résultats

=end


# Hash augmenté pour gérer la liste des liens checkés
class ListeLinksChecked < Hash

  # Liste des bases-uri à ne pas tester
  IGNORED_BASES_URI = [
    'https://twitter.com',
    'javascript:void(0)'
  ]

  class << self

    # L'instance ListeLinksChecked courante du
    # test courant qui produira le rapport final.
    def current
      @current ||= new
    end

    # ---------------------------------------------------------------------
    #   LA BOUCLE QUI TESTE TOUS LES FICHIERS
    # ---------------------------------------------------------------------
    def test_all_site_pages __tfile

      # Nombre maximum de liens à checker, pour
      # les tests.
      # Mettre à nil pour ne mettre aucune limite (pour traiter
      # tous les liens de toutes les pages)
      max_nombre_links = nil # 20

      # Indice du lien courant testé
      indice_current_link = 0

      # Liste totale des liens (instances ALink)
      @alinks = []

      # Liste des erreurs
      # Ce sont des instances d'erreur
      errors = []

      # Boucle sur tous les liens à tester
      #
      # Note : +main_link+ est une instance de la classe ALink
      while main_link = links_stack.shift

        # Ajout de ce lien à la liste totale des liens
        @alinks << main_link

        # S'il s'agit une URL à ne pas tester, on passe à la suite
        do_check = true
        IGNORED_BASES_URI.each do |base_uri|
          if main_link.href.start_with?(base_uri)
            do_check = false
            break
          end
        end
        do_check || next

        # On passe à l'indice suivant
        indice_current_link += 1

        # Liste des liens de __tfile qui seront ajoutés
        added_links     = []
        links_for_stack = []
        errors_links    = []

        __tfile.test_route main_link.href do
          description "Check du lien `#{main_link.href}`"

          # C'est ici que ce fait le test, mais on ne
          # l'interrompt pas
          begin
            responds
            main_link.responds= true
          rescue TestUnsuccessfull
            main_link.responds= false
          rescue Exception => e
            raise e
          end

          # Si le lien a produit une erreur, inutile de le
          # tester davantage
          main_link.responds? || next

          # Si le lien testé est un lien externe, on peut
          # s'en retourner tout de suite, on ne va pas tester
          # ses liens internes.
          next if main_link.externe?

          # === TEST DE TOUS LES LIENS DE LA PAGE ===
          # On récupère les liens de la page pour les tester
          html.page.css('a').each do |edom|

            # debug "edom: #{edom.inspect.gsub(/</,'&lt;')}"

            # On doit retirer tous les liens qui n'ont pas
            # de HREF (par exemple les ancres)
            edom.attributes.key?('href') || next

            ilink = ALink::new(edom, main_link)

            # Si l'élément possède la balise href, mais qu'elle est
            # vide, on passe à la suivante.
            # debug "ilink.href : #{ilink.href.inspect}"
            #
            # Ici, il peut survenir une erreur que je
            # ne comprends pas. On la mémorise et on passe
            # à la suite
            begin
              ilink.href != nil || next
            rescue Exception => e
              errors_links << [edom['href'], e]
              next
            end

            # Si l'élément possède une balise href qui commence
            # par javascript ou mailto, on la passe
            ilink.href.match(/^(javascript:|mailto:)/) && next

            # Dans tous les cas, on ajoute ce lien à la liste des
            # liens checkés (pour savoir d'où il a été appelé, etc.).
            # current << ilink
            added_links << ilink

            # Si ce lien a déjà été testé ou que c'est un lien
            # externe, on peut s'en retourner tout
            next if ilink.already_tested?

            # Sinon, on l'ajoute à la liste des liens à tester
            # plus tard ici
            # @links_stack << ilink
            links_for_stack << ilink

          end # / tous les 'a'

        end # /test_route

        # On ajoute les liens
        # Noter que les opérateurs += ne fonctionnent pas
        # pour current et links_stack
        added_links.each{|ilk| self.current << ilk }
        links_for_stack.each{|ilk| links_stack << ilk }
        errors_links.each { |perr| errors << perr }

        # S'il y a une limite, on s'arrête
        max_nombre_links.nil? || indice_current_link < max_nombre_links || break

      end # /Fin de boucle sur tous les liens à copier


      # En cas d'erreurs
      errors.empty? || begin
        error "#{errors.count} erreurs se sont produites. Consulter le debug."
        debug(
          errors.collect do |e|
            href, err = e
            "# #{href} : #{err.message}\n" +
            err.backtrace.join("\n")
          end.join("\n")
          )
      end

      # Production du rapport final
      report_output


    end #/ Fin de méthode main qui test tous les fichiers

    def report_output

      current_uri = nil


      current_from  = nil
      froms         = nil

      resultats = {
        nombre_total_liens: nil,
        alinks:             {},
        liens_morts:        [],
        nombre_liens_morts: nil,
        best_targets:       [],
        max_fois:           0,
        # URI classées par nombre de fois
        sorted:             {}
      }


      # On prépare la table des résultats
      #   - nombre d'échecs (de liens morts)
      #   - nombre de réussites (de liens vivants)
      #   - plus grande fréquence d'appels
      #   - plus grande fréquence de départ
      @alinks.sort_by{|alink| alink.uri}.each do |alink|
        if current_uri != alink.uri
          if alink.responds?
          else
            resultats[:liens_morts] << alink
          end
          current_uri   = alink.uri
          current_from  = nil
          resultats[:alinks][current_uri] = {
            alink:      alink,
            human_uri:  alink.human_uri,
            nombre:     0,
            froms:      {}
          }
        end

        # On ajoute toujours une fois pour cet URI
        resultats[:alinks][current_uri][:nombre] += 1

        if resultats[:alinks][current_uri][:nombre] > resultats[:max_fois]
          resultats[:max_fois] = resultats[:alinks][current_uri][:nombre]
        end

        huri = resultats[:alinks][current_uri][:human_uri]
        resultats[:sorted][huri] = resultats[:alinks][current_uri][:nombre]

        # Traitement des routes qui appelle la page
        # désignée par `alink`
        alink.route_from || next
        if current_from != alink.route_from.uri
          # => Nouveau "from"
          current_from = alink.route_from.human_uri # uri
          resultats[:alinks][current_uri][:froms].merge!(current_from => {
            value: current_from,
            nombre: 0
            })
        end
        # On ajoute toujours une fois pour ce from
        resultats[:alinks][current_uri][:froms][current_from][:nombre] += 1
      end

      resultats[:nombre_total_liens] = resultats[:alinks].count
      resultats[:nombre_liens_morts] = resultats[:liens_morts].count

      # On va relever les best-of
      # resultats[:best_targets] = resultats[:alinks].sort_by{|uri,duri| duri[:nombre]}[0..10]
      resultats[:best_targets] = resultats[:sorted].sort_by{|huri, nombre| - nombre }[0..10]
      debug "resultats[:best_targets]: #{resultats[:best_targets].inspect}"

      code_report = []
      code_report << "=== RAPPORT DES LIENS DU #{Time.now} ===\n"
      code_report << "= Nombre total de liens : #{resultats[:nombre_total_liens]}"
      code_report << "= Nombre de liens morts : #{resultats[:nombre_liens_morts]}"
      code_report << ''
      unless resultats[:nombre_liens_morts] == 0
        code_report << '= Liste des liens morts ='
        code_report <<
          resultats[:liens_morts].collect do |alink|
            "  - #{alink.uri} (depuis : #{alink.route_from.human_uri})"
          end.join("\n")
        code_report << ''
      end

      code_report << ''
      code_report << '=== 10 meilleures cibles ==='
      code_report << ''
      code_report <<
        resultats[:best_targets].each_with_index.collect do |puri, i|
          huri, nombre = puri
          "  #{(i+1).to_s.rjust(2)}. #{huri} (#{nombre} fois)"
        end.join("\n")

      # Mise en forme du rapport à écrire
      code_report << ''
      code_report << '=== Liste des liens par ordre alphabétique ==='
      code_report << ''
      resultats[:alinks].each do |uri, dlink|
        alink = dlink[:alink]
        code_report << "\n#{alink.responds? ? '•••' : '###'} #{alink.human_uri} (#{dlink[:nombre]} fois)"
        dlink[:froms].each do |from_uri, dfrom|
          code_report << "  Depuis: #{from_uri} (#{dfrom[:nombre]} fois)"
        end

      end


      code_report = code_report.join("\n")

      report_file.remove if report_file.exist?
      report_file.write code_report
      flash "On peut trouver le rapport des liens dans le fichier #{report_file}."

    end
    def report_file
      @report_file ||= SuperFile::new("./tmp/test/rapport_check_liens.txt")
    end

    # Propriété qui va contenir la liste de tous les
    # liens à tester.
    # C'est un Array d'instances ALink qui contient au départ un
    # lien vers l'accueil pilou
    def links_stack
      @links_stack ||= begin
        # On fake le code d'une page qui appellerait la page
        # d'accueil pour obtenir une instance ALink pour commencer
        # la recherche.
        fakedpage = "<html><head></head><body><a id='boa' href=\"site/home\">LA BOITE À OUTILS DE L’AUTEUR</a></body></html>"
        # Liste qui contient tous les liens à checker
        fakedpage = Nokogiri::HTML(fakedpage)
        linktohome = fakedpage.css('a#boa').first
        [ ALink::new(linktohome, nil) ]
      end
    end
  end #/<< self

  # Ajoute une route (une instance ALink) à la liste
  #
  # La méthode définit aussi dans l'instance +alink+ si
  # cette route a déjà été testée.
  #
  # +alink+ Instance ALink d'un lien
  def << alink
    deja_tested = true
    self[alink.uri] ||= begin
      deja_tested = false
      {}
    end
    self[alink.uri][alink.query_string] ||= begin
      deja_tested = false
      []
    end
    self[alink.uri][alink.query_string] << alink
    alink.already_tested= deja_tested
  end

end

# Pour mémoriser touts les liens
def liste_liens_checked
  @liste_liens_checked ||= ListeLinksChecked::new()
end

# Une class pour maintenir le lien et le tester
class ALink

  # {Nokogiri::XML::Element} Element récupéré
  # par `page.css`
  # Note : Nil pour la page d'accueil.
  attr_reader :noko_element

  # {String} La route depuis laquelle le lien a
  # été appelé
  attr_reader :route_from

  # +enoko+ Nokogiri::XML::Element de l'élément DOM
  def initialize enoko, route_from
    @noko_element = enoko
    @route_from   = route_from
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'état
  # ---------------------------------------------------------------------

  # Méthode principale qui indique si le lien
  # répond
  # C'est la boucle principale qui définit cette valeur
  def responds?; @is_responding end
  def responds= value; @is_responding = value end

  # Retourne true si ce lien a déjà été testé.
  #
  # Un lien a déjà été testé lorsque son uri est définie à
  # la base des liens testés et que son query_string (qui peut être
  # vide) a été testé aussi.
  def already_tested?
    @has_already_been_checked
  end

  # Retourne true si le lien href pointe vers un
  # lien externe au site. Dans ce cas, on ne le testera
  # pas à l'intérieur
  def externe?
    !(@is_externe_link === nil) || begin
      is_ext = false
      if href.start_with?('mailto')
        is_ext = true
      elsif href.start_with?('http')
        # Le lien est "externe" si sa base-uri n'est pas
        # le site lui-même
        is_ext = ! href.start_with?(site.distant_url)
      end
      @is_externe_link = is_ext
    end
    @is_externe_link
  end

  def already_tested= valeur
    @has_already_been_checked = valeur
  end

  # ---------------------------------------------------------------------
  #   Méthodes de données
  # ---------------------------------------------------------------------

  def text
    @text ||= noko_element.text
  end
  TRANS_QUERY_STRING = {
    '[' => '%5B',
    ']' => '%5D'
  }

  def href
    @href ||= begin
      r = noko_element['href']
      r, ancre = r.split('#') if r.match(/#/)
      unless r.nil? # Quand c'est une ancre seule
        # Quelques substitutions
        r.gsub!(/[\[\]]/, TRANS_QUERY_STRING)
        r.nil_if_empty
      end
    end
  end
  def id
    @id ||= noko_element['id']
  end
  def class_css
    @class_css ||= noko_element['class']
  end

  # Pour l'affichage de ce lien, avec information
  # humaine parfois. Par exemple, "site/home" est
  # transformé en "Accueil"
  def human_uri
    @human_uri ||= begin
      huri =
        case uri
        when /home$/
          case uri
          when 'site/home'        then 'Accueil'
          when 'unan/home'        then 'Programme UAUS (unan/home)'
          when 'cnarration/home'  then 'Collection Narration (cnarration/home)'
          when 'forum/home'       then 'Forum (forum/home)'
          end
        when /list$/
          case uri
          when 'tool/list'        then 'Liste des outils (tool/list)'
          end
        when /^user/
          case uri
          when 'user/signin'      then 'Formulaire d’identification (user/signin)'
          when 'user/signup'      then 'Formulaire d’inscription (user/signup)'
          when 'user/profil'      then 'Profil (user/profil)'
          end
        end
      huri || uri
    end
  end

  # Partie réelle de l'URL, sans le query-string
  # C'est cette partie qui sera mémorisée dans la table
  # des liens checkés
  def uri
    @uri ||= begin
      if href.match(/\?/)
        uri, @query_string = href.split('?')
        @query_string ||= ""
        uri
      else
        href
      end
    end
  end
  def query_string
    @query_string || uri
    @query_string
  end
end

# === Méthode qui appelle la méthode principale ===
# +self+ est l'instance SiteHtml::TestSuite::TestFile du fichier
# test courant
ListeLinksChecked.test_all_site_pages self
