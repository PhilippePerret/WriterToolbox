# encoding: UTF-8
=begin

  Ce module est censé vérifier tous les liens du site.

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
    def test_all_site_pages

      # Nombre maximum de liens à checker, pour
      # les tests
      max_nombre_links = 100000000000

      # Indice du lien courant testé
      indice_current_link = 0

      # Boucle sur tous les liens à tester
      #
      # Note : +main_link+ est une instance de la classe ALink
      while main_link = links_stack.shift

        # S'il s'agit une URL à ne pas tester, on passe à la suite
        do_not_check = false
        IGNORED_BASES_URI.each do |base_uri|
          if main_link.href.start_with?(base_uri)
            do_not_check = true
            break
          end
        end
        next if do_not_check

        # On passe à l'indice suivant
        indice_current_link += 1

        test_route main_link.href do
          description "Check du lien `#{main_link.href}`"
          responds

          # Si le lien testé est un lien externe, on peut
          # s'en retourner tout de suite, on ne va pas tester
          # ses liens internes.
          next if main_link.externe?

          # === TEST DE TOUS LES LIENS DE LA PAGE ===
          # On récupère les liens de la page pour les tester
          html.page.css('a').each do |edom|

            # On doit retirer tous les liens qui n'ont pas
            # de HREF (par exemple les ancres)
            ilink = ALink::new(edom, main_link)

            # Si l'élément possède la balise href, mais qu'elle est
            # vide, on passe à la suivante.
            next if ilink.href.nil?

            # debug "-edom::#{edom.class} / href:#{ilink.href} / text:#{ilink.text}"

            # Dans tous les cas, on ajoute ce lien à la liste des
            # liens checkés.
            ListeLinksChecked.current << ilink

            # Si ce lien a déjà été testé ou que c'est un lien
            # externe, on peut s'en retourner tout
            next if ilink.already_tested?

            # Sinon, on l'ajoute à la liste des liens à tester
            #
            links_stack << ilink

          end
        end

        # S'il y a une limite, on s'arrête
        break if indice_current_link >= max_nombre_links

      end # /Fin de boucle sur tous les liens à copier

      # On inspect le résultat
      # TODO On pourrait faire un rapport sur les liens qu'on trouve,
      # le nombre qui conduit à, etc. Peut-être une liste d'URI en particulier
      # pour classer les résultats suivant un ordre de pertinence.
      ListeLinksChecked.current.sort_by{|uri, duri| uri}.each do |uri, data_uri|
        debug "- #{uri}"
      end

    end #/ Fin de méthode main qui test tous les fichiers

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
        [ALink::new(linktohome, nil)]
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
      # Quelques substitutions
      r.gsub!(/[\[\]]/, TRANS_QUERY_STRING)
      r.nil_if_empty
    end
  end
  def id
    @id ||= noko_element['id']
  end
  def class_css
    @class_css ||= noko_element['class']
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
ListeLinksChecked.test_all_site_pages
