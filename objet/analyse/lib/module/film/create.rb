# encoding: UTF-8
class FilmAnalyse
class Film

  # Procédure pour créer le nouveau film analysé.
  # Noter que cette procédure est appelée lorsqu'un nouveau film
  # filmodico a été créé et qu'on passe par l'analyse.
  def proceed_create

    # On prend toutes les données du film Filmodico
    data_filmodico = FilmAnalyse.table_filmodico.get(id)

    debug "data_filmodico : #{data_filmodico.inspect}"

    # Le sym du film (utilisé par exemple comme affixe pour les
    # film TM)
    unless @sym
      @sym = data_filmodico[:titre].as_normalized_filename.downcase
    end

    director =
      JSON.parse(data_filmodico[:realisateur]).to_sym.collect do |hpeople|
        hpeople.instance_of?(Hash) || hpeople = JSON.parse(hpeople).to_sym
        debug "hpeople = #{hpeople.inspect}"
        "#{hpeople[:prenom]} #{hpeople[:nom]}".strip
      end.pretty_join

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

    FilmAnalyse.table_films.insert( data2create )

    debug "=== Film ##{id} créé avec succès (#{data_filmodico[:titre]})"
  rescue Exception => e
    debug e
    error e.message
  end

end #/Film
end #/FilmAnalyse
