# encoding: UTF-8
class FilmAnalyse
class Film

  # Procédure pour créer le nouveau film analysé.
  # Noter que cette procédure est appelée lorsqu'un nouveau film
  # filmodico a été créé et qu'on passe par l'analyse.
  def proceed_create

    # On prend toutes les données du film Filmodico
    data_filmodico = FilmAnalyse::table_filmodico.get( id )

    # Le sym du film (utilisé par exemple comme affixe pour les
    # film TM)
    unless @sym
      @sym = data_filmodico[:titre].as_normalized_filename.downcase
    end

    director = data_filmodico[:realisateur].collect do |hpeople|
      "#{hpeople[:prenom]} #{hpeople[:nom]}".strip
    end
    director = director.pretty_join

    data2create = {
      id:           id, # forcément défini, c'est celui du Filmodico
      titre:        data_filmodico[:titre],
      titre_fr:     data_filmodico[:titre_fr],
      film_id:      data_filmodico[:film_id],
      sym:          @sym,
      realisateur:  director,
      annee:        data_filmodico[:annee],
      updated_at:   NOW,
      created_at:   NOW
    }

    FilmAnalyse::table_films.insert( data2create )

    debug "=== Film ##{id} créé avec succès (#{titre})"
  rescue Exception => e
    debug e
    error e.message
  end

end #/Film
end #/FilmAnalyse
