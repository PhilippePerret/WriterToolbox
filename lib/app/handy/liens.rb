# encoding: UTF-8
=begin

# Si un lien est ajouté, il faut l'ajouter aussi à la section
# liens de l'aide : ./lib/app/console/help_app.yml

Extension de la classe Lien, pour l'application courante

Rappel : c'est un singleton, on appelle les méthodes par :

    lien.<nom méthode>[ <args>]

=end
class Lien

  # Pour écrire dans la page un texte un plus explicatif sur
  # les raisons de s'abonner au site. On indique simplement en
  # amorce le texte qui correspond à la page. Par exemple, dans
  # la section Citations, un non abonné ne peut consulter que
  # 5 citations. À la sixième, il trouve le texte "Pour consulter
  # d'autre citation, merci de soutenir le travail de la boite à
  # outils etc.". Le texte à partir de ", merci de soutinir" est
  # fourni ici.
  def bloc_soutien amorce
    (
      '<img src="./view/img/mascotte/mascotte-50pc.png" style="float:left;margin-right:1em;margin-bottom:1em;" />' +
      "#{amorce}, merci de soutenir les efforts et le travail de #{site.name} en vous abonnant ! ;-)<br>Cela représente une petite somme pour vous, mais c'est d'une aide infinie et préciseuse pour nous !" +
      bouton_subscribe(align: :right, visible: true, filled: true).in_div(class: 'big air')
    ).in_div(style: 'font-weight: bold;padding:3em 4em 0em 1em;width:70%;margin-left:10%;font-size:14pt;', class: 'cadre air')
  end

  # Lien vers le programme ÉCRIRE UN FILM/ROMAN EN UN AN
  def unanunscript titre = nil, options = nil
    titre ||= "programme #{UN_AN_UN_SCRIPT}"
    build('unan/home', titre, options)
  end
  # Lien vers l'inscription au programme ÉCRIRE UN FILM/ROMAN EN UN AN
  def unanunscript_subscribe titre = nil, options = nil
    titre ||= "S'inscrire au programme #{UN_AN_UN_SCRIPT}"
    build("unan/paiement", titre, options)
  end
  alias :subscribe_unanunscript :unanunscript_subscribe

  # Lien vers la partie analyse de films
  # @usage : <%= lien.analyses %> ou <%= lien.analyses_de_films %>
  def analyses_de_films titre = "analyses de films", options = nil
    build("analyse/home", titre, options)
  end
  alias :analyses_films :analyses_de_films

  def analyses titre = "analyses", options = nil
    analyses_de_films titre, options
  end
  # Lien vers le collecteur online permettant de procéder
  # à des collectes en bénéficiant des mêmes outils que dans
  # TextMate
  def collecteur_analyse titre = "collecteur d'analyse", options = nil
    build("analyse/collecteur", titre, options)
  end

  # Liste complète et détaillée des outils
  def outils titre = "liste des outils", options = nil
    build("tool/list", titre, options)
  end

  LIENS_CNARRATION = {
    home:       ["Collection Narration", 'cnarration/home'],
    recherche:  ["Formulaire de recherche dans les pages", "cnarration/search"],
    livres:     ["Tous les livres", 'livre/tdm?in=cnarration'],
    books:      ["Tous les livres", 'livre/tdm?in=cnarration'],
    page:       ["Une page", '']
  }
  # Pour atteindre la collection Narration.
  # En utilisant options[:at] on peut définir une sous-rubrique
  # +options+
  #   :to       Pour envoyer dans une partie particulière (cf.
  #             LIENS_CNARRATION ci-dessus)
  #   :id       ID de la page si    :to = page
  #   :titre    TITRE de la page si :to = page. S'il n'est pas fourni,
  #             il est recherché dans la table.
  #             Si la page se trouve dans un autre livre que le livre
  #             de la page courante (:from_livre), alors le livre est
  #             ajouté au titre à afficher.
  #   :ancre    Une ancre éventuelle
  #   :from_book  ID du livre pour lequel le lien est créé.
  def cnarration titre = nil, options = nil
    if titre.instance_of? Hash
      options   = titre
      titre     = nil
    end
    options ||= Hash.new

    to = options.delete(:to) || :home
    titre, href = if to == :page
      # ID de la page
      pid   = options[:id]
      site.require_objet 'cnarration'
      hpage = Cnarration::table_pages.get(pid, colonnes:[:titre, :livre_id])
      raise "La page ##{pid.inspect} est introuvable" if hpage.nil?
      livre_id = hpage[:livre_id]
      # ID du livre
      titre = options[:titre].nil_if_empty || begin
        # Il faut rechercher le titre dans la table des pages
        hpage[:titre]
      end
      titre = "<span class='page'>#{titre}</span>"
      if options[:from_book] != livre_id
        # C'est un lien pour un autre livre, il faut donc indiquer
        # le titre du livre
        titre_livre = Cnarration::LIVRES[livre_id][:hname]
        titre += " dans <span class='livre'>#{titre_livre}</span>"
      end
      [titre, "page/#{pid}/show?in=cnarration"]
    else
      LIENS_CNARRATION[ to ]
    end
    build(href, titre, options)
  rescue Exception => e
    debug e
    error e.message
    "#{titre.inspect}"
  end
  alias :collection_narration :cnarration
  alias :narration :cnarration

  def forum titre = "forum", options = nil
    build('forum/home', titre, options)
  end
  def forum_de_discussion titre = "forum de discussion", options = nil
    forum titre, options
  end

  # Retourne le lien scénodico pour le mot d'identifiant +mot_id+ qui
  # est +mot_str+
  # Pour le moment, il faut obligatoirement fournir l'ID du mot et
  # le mot lui-même. Plus tard, on pourra voir s'il est intéressant
  # de ne pouvoir fournir que l'ID
  #
  # C'est la méthode qui est utilisée pour formater les liens
  # qui sont définis par `MOT[<mot_id>, <mot>]` dans les textes.
  #
  def mot mot_id, mot_str, options = nil
    options ||= {}
    options.merge!( class:'mot', target:'_blank' )
    build("scenodico/#{mot_id}/show", mot_str, options)
  end

  # Retourne un lien pour lire la citation d'identifiant
  # +cit+ avec le titre +titre+
  def citation cit, titre, options = nil
    options ||= {}
    options.merge!( target: '_blank')
    build("citation/#{cit}/show", titre, options)
  end

  # Lien vers le filmodico
  # @usage: lien.filmodico("TITRE")
  def filmodico titre = nil, options = nil
    options ||= Hash.new
    titre ||= options.delete(:titre) || "Filmodico"
    case output_format
    when :latex
      "#{titre} sur le site LA BOITE À OUTILS DE L'AUTEUR"
    else
      options.merge!(href: "filmodico/home")
      options.merge!(target: "_blank") unless options.has_key?(:target)
      titre.in_a(options)
    end
  end

  # Liens vers le scénodico
  # @usage: lien.scenodico("TITRE")
  def scenodico titre = nil, options = nil
    options ||= Hash.new
    titre ||= options.delete(:titre) || "Scénodico"
    case output_format
    when :latex
      "#{titre} sur le site LA BOITE À OUTILS DE L'AUTEUR"
    else
      options.merge!(href: "scenodico/home")
      options.merge!(target: "_blank") unless options.has_key?(:target)
      titre.in_a(options)
    end
  end

  # Retourne un lien vers un film d'après la référence fournie
  # +film_ref+ qui peut être l'ID dans la table des films ou l'ID string
  # tel qu'il est connu ailleurs (par exemple `DancerInTheDark2001`)
  #
  # C'est la méthode qui est utilisée pour formater les liens
  # qui sont définis par `FILM[<film_id>]` dans les textes.
  #
  def film film_ref, options = nil
    # Pour faciliter le travail, on charge les librairies
    # filmodico
    @lib_filmodico_already_required ||= begin
      site.require_objet 'filmodico'
      @lib_filmodico_already_required = true
    end

    options ||= Hash.new


    # On mémorise les films déjà cités pour ne pas mettre plusieurs
    # fois leur année et leur réalisateur.
    # Donc : La première fois, on donne toutes les informations et
    # les fois suivantes où le film apparait on ne donne que son
    # titre.
    @films_already_cited ||= {}

    # -> MYSQL FILMODICO
    @table_filmodico ||= Filmodico.table_filmodico
    cols = [:titre, :titre_fr, :annee, :realisateur]

    # On récupère le film dans la table (analyse.films) avec la
    # référence donné.
    film_id =
      case film_ref
      when String
        film_for_id = @table_filmodico.select(where: {film_id: film_ref}, colonnes:[]).first
        if film_for_id.nil?
          error "Impossible d'obtenir le lien vers le film #{film_ref}."
          nil
        else
          film_for_id[:id]
        end
      when Fixnum
        film_ref
      else
        error "Impossible d'obtenir le lien vers le film #{film_ref} (la référence devrait être un string ou un fixnum)"
        nil
      end
    film_id != nil || ( return film_ref )

    # Le titre, en fonction du fait que le film a déjà été cité une fois
    # ou non. Si le film a déjà été cité, on a mémorisé les deux
    # titres possibles, il suffit de le prendre. Sinon, on le
    # construit
    film_deja_cited = @films_already_cited.key?(film_id)
    @films_already_cited[film_id] ||= begin

      # --- CONSTRUCTION DES DEUX TITRES ---

      # Instance du film
      ifilm = Filmodico.get( film_id )

      # Cas du film introuvable, on retourne la référence en indiquant
      # dans le texte que ce film est introuvable.
      titre_premiere_fois, titre_autres_fois =
        if ifilm != nil
          titre_autres_fois = "#{ifilm.titre.in_span(class:'titre')}"
          t = "#{(options.delete(:titre) || ifilm.titre).in_span(class:'titre')} ("
          t << ifilm.titre_fr.in_span(class:'italic') + " – " if ifilm.titre_fr.to_s != ""
          realisateur = ifilm.realisateur.collect do |hreal|
            "#{hreal[:prenom]} #{hreal[:nom]}"
          end.pretty_join
          t << "#{realisateur}, #{ifilm.annee}"
          t << ")"
          [t, titre_autres_fois]
        else
          ["#{film_ref} [INTROUVABLE]", "#{film_ref} [INTROUVABLE]"]
        end
    end

    titre =
      if film_deja_cited
        @films_already_cited[film_id][1]
      else
        @films_already_cited[film_id][0]
      end

    # On construit et on renvoie le lien
    options.merge!(class:'film')
    build("filmodico/#{film_id}/show", titre, options )
  end

  # Balise pour des livres avec référence
  #
  # Ces livres doivent être définis dans Cnarration::BIBLIOGRAPHIE
  # Cf. l'adresse ci-dessous.
  #
  def livre titre, ref = nil
    debug "titre : #{titre.inspect}"
    debug "ref : #{ref.inspect}"
    if titre.nil_if_empty.nil? || ref != nil
      defined?(Cnarration) || begin
        require './objet/cnarration/lib/required/bibliographie.rb'
      end
      hlivre  = Cnarration::BIBLIOGRAPHIE[ref]
      titre   ||= hlivre[:titre]
    end
    case output_format
    when :latex
      "\\livre{#{titre}}\\cite{#{ref}}"
    else
      "<span class='livre'>#{titre}</span> (#{hlivre[:auteur]}, #{hlivre[:annee]})"
    end
  end

end
