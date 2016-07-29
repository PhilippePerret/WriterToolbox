# encoding: UTF-8
=begin
Extension de la class FilmAnalyse::Film (méthodes d'instance) pour
la gestion des options
=end
class FilmAnalyse
class Film

  def gbit x
    options[x].to_i
  end

  # BIT 1 (analysé)
  # Mis à 1 si le film eset analysé
  def bit_analyzed; @bit_analyzed ||= gbit(0) end
  # BIT 2 (signup)
  # Est mis à 1 si l'user a besoin d'être inscrit
  # pour consulter l'analyse
  def bit_signup; @bit_signup ||= gbit(1) end
  # BIT 3 (abonné)
  # Mis à 1 s'il faut que l'user soit abonné pour
  # consulter le film
  def bit_suscribed; @bit_suscribed ||= gbit(2) end
  # BIT 4
  # Définit le type de l'analyse (comparaison de bit)
  #   1 => TM
  #   2 => MYE
  #   1+2 => TM et MYE
  def bit_type_analyse; @bit_type_analyse ||= gbit(3) end
  # BIT 5 (lisible)
  # Mis à 1 si l'analyse est lisible
  def bit_lisible; @bit_lisible ||= gbit(4) end
  # BIT 6 (en cours)
  # Mis à 1 si l'analyse est en cours
  def bit_encours; @bit_encours ||= gbit(5) end
  # BIT 7 (en lecture)
  # Mis à 1 si l'analyse est en cours de relecture
  def bit_enlecture; @bit_enlecture ||= gbit(6) end
  # BIT 8 (achevée)
  # Mis à 1 si l'analyse est achevée
  def bit_complete; @bit_complete ||= gbit(7) end
  # BIT 9 (quelques notes)
  def bit_small;    @bit_small ||= gbit(8)    end

end #/Film
end #/FilmAnalyse
