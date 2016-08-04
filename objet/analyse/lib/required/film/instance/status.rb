# encoding: UTF-8
class FilmAnalyse
class Film

  # Retourne true si l'utilisateur courant est
  # autorisé à voir l'analyse du film courant
  def consultable?
    # Un administrateur ou un analyse réel peuvent toujours
    # consulter les analyses, quel que soit leur stade
    # d'avancement.
    # Un bot google aussi
    return true if user.authorization_level.to_i > 3 || user.authorized? || user.real_analyste?

    # Pour les autres utilisateurs, il faut que l'analyse
    # soit au moins lisible pour qu'ils puissent la consulter

    # Si l'analyse n'a besoin d'aucun privilège, elle est
    # toujours visible
    return true if !need_signedup? && !need_suscribed?

    return true if need_suscribed? && user.suscribed?

    return true if need_signedup? && user.identified?

    # Dans tous les autres cas, l'utilisateur n'a pas le
    # droit de consulter cette analyse.
    return false
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
  def need_suscribed?
    bit_suscribed == 1
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
