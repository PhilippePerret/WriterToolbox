# encoding: UTF-8
=begin
Extension de la class FilmAnalyse::Film (méthodes d'instance) pour
la gestion des options
=end
class FilmAnalyse
class Film

  # BIT 1 Détermine si l'analyse fait partie des analyses du
  # site (analyses dites “Film TM” car elles sont réalisées avec TextMate)
  def analyzed?
    options[0].to_i == 1
  end

  # BIT 2 Indique si l'analyse, qui fait partie des analyses du site
  # peut être consultée (ou si elle est en cours)
  # 0: Non analysée
  # 1: Analyse tout juste débutée
  # 5: Non terminée mais consultable
  # 9: Achevée complètement
  def analyse_lisible?
    options[1].to_i > 5
  end


end #/Film
end #/FilmAnalyse
