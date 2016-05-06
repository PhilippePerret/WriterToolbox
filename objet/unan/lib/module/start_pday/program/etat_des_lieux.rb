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
    # s'en retourner tout de suite.
    return true if cur_pday.undone(:all).count == 0

    # Pour consigner le nombre d'avertissements par niveau en
    # enregistrant les instances travaux dans les listes.
    # Par exemple, la donnée de clé 3 correspond à l'avertissement
    # de niveau 3 et contient dans sa liste tous les travaux qui
    # ont atteint ce niveau d'avertissement
    #
    # (*) Les abs-works augemntés contiennent en plus un
    #     indice de P-Day et un work-id si le travail a
    #     été défini.
    avertissements = {
      1 => Array::new(), # Liste de données AbsWork augmentées (*)
      2 => Array::new(),
      3 => Array::new(),
      4 => Array::new(),
      5 => Array::new(),
      6 => Array::new(),
      # Nombre total d'avertissements
      total:              0,
      # Nombre d'avertissements supérieurs à 4, donc
      # d'avertissement graves
      greater_than_four:  0
    }

    cur_pday.undone(:all).each do |wdata|
      niv_alerte = Unan::Program::Alerts::niveau_alerte_depassement(wdata[:depassement])
      unless niv_alerte.nil?
        # Travail en dépassement
        avertissements[niv_alerte] << wdata
        avertissements[:total] += 1
        avertissements[:greater_than_four] += 1 if niv_alerte > 4
        wdata.merge!(css: 'warning')
        message_alerte = Unan::Program::Alerts::message_alerte_depassement(niv_alerte)
        wdata[:titre] += " (#{message_alerte})"
      end
      # On ajoute le travail à la liste des travaux courants dans
      # le mail
      mail_auteur.travaux_courants << wdata[:titre].in_li(class: wdata[:css])
    end

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
