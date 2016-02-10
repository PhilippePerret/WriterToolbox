# encoding: UTF-8
=begin
Extension de la class FilmAnalyse::Film (méthodes d'instance) pour
les données du film
=end
class FilmAnalyse
class Film

  def titre         ; @titre        ||= get(:titre)       end
  def titre_fr      ; @titre_fr     ||= get(:titre_fr)    end
  def annee         ; @annee        ||= get(:annee)       end
  def pays          ; @pays         ||= get(:pays)        end
  def realisateur   ; @realisateur  ||= get(:realisateur) end
  def auteurs       ; @auteurs      ||= get(:auteurs)     end
  def options       ; @options      ||= get(:options)||"" end

end #/Film
end #/FilmAnalyse
