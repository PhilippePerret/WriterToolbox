# encoding: UTF-8
class FilmAnalyse
class Film

  # Retourne true si l'utilisateur courant est
  # autorisé à voir l'analyse du film courant
  def consultable?
    # Maintenant, tous les films sont consultables
    # (ils seront retirés à mesure qu'ils seront édités)
    return true
  end

  # BIT 1 Analysé / Non analysé
  def analyzed?
    bit_analyzed == 1
  end
  # BIT 2 A besoin d'être inscrit
  def need_signedup?
    bit_signup == 1
  end
  # BIT 3 À besoin d'être abonné
  def need_subscribed?
    bit_subscribed == 1
  end
  # BIT 4 C'est une analyse TM
  def analyse_tm?
    (bit_type_analyse & 1) > 0
  end
  # BIT 4 C'est une analyse de type MYE, c'est-à-dire
  # Markdown, Yaml et Evt
  def analyse_mye?
    (bit_type_analyse & 2) > 0
  end
  # BIT 4 C'est une analyse TM et MYE
  def analyse_mixte?
    (bit_type_analyse & 3) > 0
  end
  # BIT 5 Lisible / non lisible
  def lisible?
    bit_lisible == 1
  end
  # BIT 6 Analyse en cours / pas en cours
  def en_cours?
    bit_encours == 1
  end
  # BIT 7 Analyse en lecture / pas en lecture
  def en_lecture?
    bit_enlecture == 1
  end
  # BIT 8 Analyse achevée / non achevée
  def complete?
    bit_complete == 1
  end
  # BIT 9 Seulement quelques notes
  def quelques_notes?
    bit_small == 1
  end


end #/Film
end #/FilmAnalsye
