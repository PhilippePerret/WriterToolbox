# encoding: UTF-8
=begin
Class Unan::Program::StarterPDay
--------------------------------
Extention pour l'état des lieux
=end
class Unan
class Program

  # = main =
  #
  # Méthode principale qui procède à un état des lieux du
  # programme d'un auteur (c'est le programme qui est le
  # cœur de la méthode)
  #
  # Maintenant, la méthode fonctionne avec la classe
  # Unan::Program::CurPDay qui contient toutes les méthodes
  # efficace pour voir où on en est très simplement.
  #
  # Note : Cette méthode est appelée AVANT le changement de
  # jour-programme si ce changement doit avoir lieu (car il
  # n'a pas forcément lieu si l'auteur est en rythme très lent)
  def etat_des_lieux

    # S'il n'y a aucun travail à faire (tous exécutés), on peut
    # s'en retourner tout de suite. Mais en fait, ça ne peut pas
    # arriver car il y a toujours, au moins, des travaux à
    # poursuivre. Aucun jour n'a aucun travail, pas même le tout
    # premier.
    # return true if cur_pday.undone(:all).count == 0

    # Les avertissements calculés
    avertissements = auteur.current_pday.warnings

    # S'il y a plus de 5 travaux en niveau d'avertissement
    # supérieur à 4 (:greater_than_four) il faut avertir
    # l'administration
    # NOTE Remarquer qu'on utilise ici la classe Cron donc que
    # cette méthode n'est utilisable, pour le moment, qu'avec le
    # cron
    if avertissements[:greater_than_four] > 4
      Cron::rapport_admin.depassements.merge!(
        auteur.id => "#{auteur.pseudo} (##{auteur.id}) est en sur-dépassement (nombre de travaux en avertissement supérieur à 4 : #{avertissements[:greater_than_four]})."
      )
    end

  rescue Exception => e
    log "#ERR: #{e.message}"
    log "#BACKTRACE:\n# " + e.backtrace.join("\n# ")
    return false
  else
    true
  end

end #/Program
end #/Unan
