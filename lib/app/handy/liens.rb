# encoding: UTF-8
=begin

Extension de la classe Lien, pour l'application courante

Rappel : c'est un singleton, on appelle les méthodes par :

    lien.<nom méthode>[ <args>]

=end
class Lien

  # Lien vers le programme UN AN UN SCRIPT
  def unanunscript titre = nil, options = nil
    titre ||= "programme #{UN_AN_UN_SCRIPT}"
    build('unan/home', titre, options)
  end
  # Lien vers l'inscription au programme UN AN UN SCRIPT
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

  def cnarration titre = "Collection Narration", options = nil
    build("cnarration/home", titre, options)
  end
  alias :collection_narration :cnarration

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
  def mot mot_id, mot_str, options = nil
    options ||= Hash::new
    options.merge!( class:'mot', target:'_blank' )
    build("scenodico/#{mot_id}/show", mot_str, options)
  end

  # Lien vers le filmodico
  # @usage: lien.filmodico("TITRE")
  def filmodico titre = nil, options = nil
    options ||= Hash::new
    titre ||= options.delete(:titre) || "Filmodico"
    options.merge!(href: "filmodico/home")
    options.merge!(target: "_blank") unless options.has_key?(:target)
    titre.in_a(options)
  end

  # Liens vers le scénodico
  # @usage: lien.scenodico("TITRE")
  def scenodico titre = nil, options = nil
    options ||= Hash::new
    titre ||= options.delete(:titre) || "Scénodico"
    options.merge!(href: "scenodico/home")
    options.merge!(target: "_blank") unless options.has_key?(:target)
    titre.in_a(options)
  end

  # Retourne un lien vers un film d'après la référence fournie
  # +film_ref+ qui peut être l'ID dans la table des films ou l'ID string
  # tel qu'il est connu ailleurs (par exemple `DancerInTheDark2001`)
  def film film_ref, options = nil
    options ||= Hash::new
    # On mémorise les films déjà cités pour ne pas mettre plusieurs
    # fois leur année et leur réalisateur
    @films_already_cited ||= Hash::new
    # table_film = site.db.create_table_if_needed('analyse', 'films')
    table_film = site.db.create_table_if_needed('filmodico', 'films')
    cols = [:titre, :titre_fr, :annee, :realisateur]

    # On récupère le film dans la table (analyse.films) avec la
    # référence donné.
    case film_ref
    when String
      hfilm = table_film.select(where:{film_id: film_ref}, colonnes:cols).values.first
    when Fixnum
      hfilm = table_film.get(film_ref, colonnes:cols)
    else
      error "Impossible d'obtenir le lien vers le film #{film_ref} (la référence devrait être un string ou un fixnum)"
      return film_ref
    end

    # Cas du film introuvable, on retourne la référence en indiquant
    # dans le texte que ce film est introuvable.
    if hfilm.nil?
      return "#{film_ref} [INTROUVABLE]"
    end

    film_id = hfilm[:id]

    # Le titre, en fonction du fait que le film a déjà été cité une fois
    # ou non.
    titre = if @films_already_cited[film_id] == true
      "#{hfilm[:titre].in_span(class:'titre')}"
    else
      # On commence par indiquer que le film a déjà été cité
      @films_already_cited.merge!(film_id => true)
      t = "#{hfilm[:titre].in_span(class:'titre')} ("
      t << hfilm[:titre_fr].in_span(class:'italic') + " – " if hfilm[:titre_fr].to_s != ""
      realisateur = hfilm[:realisateur].collect do |hreal|
        "#{hreal[:prenom]} #{hreal[:nom]}"
      end.pretty_join
      t << "#{realisateur}, #{hfilm[:annee]}"
      t << ")"
      t
    end
    # On construit et on renvoie le lien
    options.merge!(class:'film')
    build("filmodico/#{film_id}/show", titre, options )
  end

end
