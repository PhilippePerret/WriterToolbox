# encoding: UTF-8
=begin
Class Unan::Program::StarterPDay
--------------------------------
Extention pour l'état des lieux
=end
class Unan
class Program
class StarterPDay

  # Fais l'état des lieux du programme avant son changement
  # de jour-programme.
  # En même temps, on relève les travaux courants (qui restent)
  # pour les signaler à l'auteur en cas de nouveau jour ou
  # lorsque l'auteur veut recevoir un mail journalier.
  def etat_des_lieux_program

    nombre_travaux = work_ids.count

    # S'il n'y a aucun travail à faire (tous exécutés), on peut
    # s'en retourner tout de suite.
    return true if nombre_travaux == 0


    # Pour consigner le nombre d'avertissements par niveau en
    # enregistrant les instances travaux dans les listes.
    # Par exemple, la donnée de clé 3 correspond à l'avertissement
    # de niveau 3 et contient dans sa liste tous les travaux qui
    # ont atteint ce niveau d'avertissement
    avertissements = {
      1 => Array::new(),
      2 => Array::new(),
      3 => Array::new(),
      4 => Array::new(),
      5 => Array::new(),
      6 => Array::new(),
      total:0,
      greater_than_four:0
    }

  rescue Exception => e
    error e.message
  else
    true
  end

end #/StarterPDay
end #/Program
end #/Unan
