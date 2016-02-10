# encoding: UTF-8
class FilmAnalyse
  class << self

    def require_module module_name

    end

    def titre_h1 sous_titre = nil
      "Analyses de films".in_h1 +
      (sous_titre ? sous_titre.in_h2 : "") +
      onglets
    end

    # Les onglets communs à toutes les pages qui font
    # appel à `titre_h1`
    def onglets
      onglets = {
        "Accueil"     => 'analyse/home',
        "Analyses"    => 'analyse/list',
        "Participer"  => 'analyse/participer',
        "Grades"      => 'analyse/grades'
      }
      onglets.merge!("MON BUREAU" => 'analyse/bureau_perso') if user.analyste?
      onglets.collect do |tit, href|
        tit.in_a(href:href).in_li
      end.join.in_ul(class: 'small onglets')

    end

    # {BdD::Table} La table contenant les informations minimales sur
    # les films.
    def table_films
      @table_films ||= site.db.create_table_if_needed('analyse', 'films')
    end

    # Dossier contenant les analyses
    def folder_films
      @folder_analyses ||= begin
        d = site.folder_data+'analyse/films'
        d.build unless d.exist?
        d
      end
    end

    # Crée un film dans la table analyse.films. C'est la méthode pour
    # le moment utilisée par la console avec la commande `create film`.

    def create_film dfilm
      # debug "dfilm : #{dfilm.inspect}"
      # On vérifie qu'il y a les informations minimales
      raise "Il faut indiquer le `sym` du film (:sym)"    unless dfilm[:sym]
      raise "Il faut indiquer le titre du film (:titre)"  unless dfilm[:titre]

      # On regarde si des options ont été précisées
      analyzed = dfilm.delete(:analyzed)
      lisible  = dfilm.delete(:lisible)
      complete = dfilm.delete(:complete)

      options = (analyzed || lisible || complete) ? "1" : "0"
      if complete     then options << "9"
      elsif lisible   then options << "5"
      elsif analyzed  then options << "1"
      else                 options << "0"
      end

      dfilm.merge!(
        options: options,
        created_at: NOW,
        updated_at: NOW
      )

      film_id = table_films.insert( dfilm )
      flash "Film créé avec succès"
      return "ID nouveau film : #{film_id}"
    rescue Exception => e
      debug e
      "# ERROR : #{e.message}"
    end

  end # << self
end #/FilmAnalyse
