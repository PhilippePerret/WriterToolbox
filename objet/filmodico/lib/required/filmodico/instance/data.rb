# encoding: UTF-8
class Filmodico

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def film_id     ; @film_id      ||= get(:film_id)               end
  def titre       ; @titre        ||= get(:titre).force_encoding('utf-8') end
  def titre_fr    ; @titre_fr     ||= get(:titre_fr).nil_if_empty end
  def resume      ; @resume       ||= get(:resume)                end
  def annee       ; @annee        ||= get(:annee)                 end
  def duree       ; @duree        ||= get(:duree)                 end
  def pays        ; @pays         ||= get(:pays)                  end
  def realisateur ; @realisateur  ||= get(:realisateur)           end
  def producteurs ; @producteurs  ||= get(:producteurs)           end
  def auteurs     ; @auteurs      ||= get(:auteurs)               end
  def acteurs     ; @acteurs      ||= get(:acteurs)               end
  def musique     ; @musique      ||= get(:musique)               end
  def links       ; @links        ||= get(:links)                 end

end
