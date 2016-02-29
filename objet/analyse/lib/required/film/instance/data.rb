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
  def film_id
    @film_id ||= begin
      FilmAnalyse::table_filmodico.get(id, colonnes:[:film_id])[:film_id]
    end
  end

  def titre         ; @titre        ||= get(:titre)       end
  def titre_fr      ; @titre_fr     ||= get(:titre_fr)    end
  def annee         ; @annee        ||= get(:annee)       end
  def pays          ; @pays         ||= get(:pays)        end
  def realisateur   ; @realisateur  ||= get(:realisateur) end
  def auteurs       ; @auteurs      ||= get(:auteurs)     end
  def options       ; @options      ||= get(:options)||"" end
  def sym           ; @sym          ||= get(:sym)         end

end #/Film
end #/FilmAnalyse
