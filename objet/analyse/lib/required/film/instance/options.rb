# encoding: UTF-8
=begin
Extension de la class FilmAnalyse::Film (méthodes d'instance) pour
la gestion des options
=end
class FilmAnalyse
class Film


  # BIT 1 Analysé / Non analysé
  def analyzed?
    options[0].to_i == 1
  end
  # BIT 2 A besoin d'être inscrit
  def need_signedup?
    options[1].to_i == 1
  end
  # BIT 3 À besoin d'être abonné
  def need_subscribed?
    options[2].to_i == 1
  end
  # BIT 4 C'est une analyse TM
  def analyse_tm?
    (options[3].to_i & 1) > 0
  end
  def analyse_mye?
    (options[3].to_i & 2) > 0
  end
  def analyse_mixte?
    (options[3].to_i & 3) > 0
  end
  # BIT 5 Lisible / non lisible
  def lisible?
    options[4].to_i == 1
  end
  # BIT 6 Analyse en cours / pas en cours
  def en_cours?
    options[5].to_i == 1
  end
  # BIT 7 Analyse en lecture / pas en lecture
  def en_lecture?
    options[6].to_i == 1
  end
  # BIT 8 Analyse achevée / non achevée
  def complete?
    options[7].to_i == 1
  end

end #/Film
end #/FilmAnalyse
