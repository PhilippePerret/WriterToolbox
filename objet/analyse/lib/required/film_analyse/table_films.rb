# encoding: UTF-8
=begin
Extension de FilmAnalyse pour les commandes de console
=end
class FilmAnalyse
  class << self


    # Affiche la liste des films dans la table analyse.films, pour
    # la console (et seulement par et pour la console).
    # Répond à `list films` ou `affiche table films`
    def films_in_table
      console.show_table self.table_films
      "OK"
    rescue Exception => e
      debug e
      "# ERROR: #{e.message}"
    end


    # Crée un film dans la table analyse.films. C'est la méthode pour
    # le moment utilisée par la console avec la commande `create film`.
    def create_film dfilm
      # debug "dfilm : #{dfilm.inspect}"
      # On vérifie qu'il y a les informations minimales
      raise "Il faut indiquer le `sym` du film (:sym)"    unless dfilm[:sym]
      raise "Il faut indiquer le titre du film (:titre)"  unless dfilm[:titre]

      dfilm = ( conforme_data dfilm )
      dfilm.merge!( created_at:NOW )

      film_id = table_films.insert( dfilm )
      flash "Film créé avec succès"
      return "ID nouveau film : #{film_id}"
    rescue Exception => e
      debug e
      "# ERROR : #{e.message}"
    end


    # Actualise les données d'un film existant
    def update_film film_ref, dfilm
      if film_ref.instance_of?(String)
        hfilm = table_films.select(colonnes:[:options], where:"sym = '#{film_ref}'").values.first
        film_ref = hfilm[:id]
      else
        hfilm = table_films.get(film_ref, colonnes:[:options])
      end
      dfilm.merge!(options: hfilm[:options]) unless dfilm.has_key?(:options)

      dfilm = ( conforme_data dfilm )

      table_films.update(film_ref, dfilm)
      # Pour vérifier, on ré-affiche toujours la liste des films
      # (en tout cas tant qu'il n'y en a pas trop…)
      films_in_table
    end

    # Prend les données +dfilm+ telles qu'envoyées à la console par
    # exemple et les transforme en vraies données pour la table
    # analyse.films.
    def conforme_data dfilm
      # On regarde si des options ont été précisées
      analyzed = dfilm.delete(:analyzed)
      lisible  = dfilm.delete(:lisible)
      complete = dfilm.delete(:complete)
      dfilm[:options] ||= "00"

      options = (analyzed || lisible || complete) ? "1" : dfilm[:options][0]
      if complete     then options << "9"
      elsif lisible   then options << "5"
      elsif analyzed  then options << "1"
      else options << dfilm[:options][1]
      end

      dfilm.merge!(
        options:    options,
        updated_at: NOW
      )
    end

  end # << self
end #/FilmAnalyse
