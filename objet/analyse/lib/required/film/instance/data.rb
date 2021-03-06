# encoding: UTF-8
=begin
Extension de la class FilmAnalyse::Film (méthodes d'instance) pour
les données du film
=end
class FilmAnalyse
class Film

  # Attention :
  #   1. Ça n'est pas l'identifiant Fixnum mais l'identifiant
  #      string tel que 21Grams2003
  #   2. Il n'est pas toujours par défaut puisque c'est un
  #      attribut qui vient du filmodico, pas des films TM.
  #   3. On définit ce `attr_writer` car lorsque la méthode
  #      `FilmAnalyse::Film::get` est utilisée avec un film_id
  #      on le définit directement pour ne pas avoir à le
  #      rechercher.
  attr_writer :film_id
  def film_id   ; @film_id  ||= filmodico_data[:film_id]  end
  def duree     ; @duree    ||= filmodico_data[:duree]    end
  def auteurs   ; @auteurs  ||= filmodico_data[:auteurs]  end
  def filmodico_data
    @filmodico_data ||= FilmAnalyse.table_filmodico.get(id)
  end

  def titre         ; @titre        ||= get(:titre).force_encoding('utf-8') end
  def titre_fr      ; @titre_fr     ||= get(:titre_fr)    end
  def annee         ; @annee        ||= get(:annee)       end
  def pays          ; @pays         ||= get(:pays)        end
  def realisateur   ; @realisateur  ||= get(:realisateur) end
  def options       ; @options      ||= get(:options)||"" end
  def sym           ; @sym          ||= get(:sym)         end

  # Exécute la méthode super mais définit aussi @titre.
  # Il faut retourner quand même toutes les données
  def get_all
    super
    @titre = @titre.force_encoding('utf-8')
    return @_data
  end

end #/Film
end #/FilmAnalyse
