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

    # S'il n'y a aucun travail à faire (tous exécutés), on peut
    # s'en retourner tout de suite.
    return true if nombre_travaux_courants == 0


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

    # Boucle sur tous les travaux courants
    # +iwork+ est une instance Work, pas AbsWork
    works.each do |iwork|

      # Le travail absolu correspondant (pour pouvoir récupérer
      # le titre)
      abs_work = Unan::Program::AbsWork::get(iwork.abs_work_id)

      titre = abs_work

      if iwork.niveau_avertissement != nil
        # Le travail est en dépassement de jours de travail
        # Il faut faire une alerte en fonction du niveau de
        # dépassement, qui est une valeur de 1 à 6, du plus en
        # plus intense. À 1, l'auteur a 3 jours de dépassement,
        # à 6, il a plus d'un mois et demi.
        #
        # La propriété  `message_avertissement` contient le
        # message en fonction du niveau d'avertissement, message
        # qui sera ajouté au titre avec une mise en exergue du titre
        titre += " (#{message_avertissement})"
        avertissement[niveau_avertissement] << iwork
        avertissement[:greater_than_four] += 1 if niveau_avertissement > 4
        class_css = 'warning'
      else
        # Si le travail n'est pas en dépassement
        class_css = nil
      end

      # On ajoute le travail à la liste des travaux courants dans
      # le mail
      mail_auteur.travaux_courants << titre.in_li(class: class_css)

    end # Fin de boucle sur tous les travaux courants

    # S'il y a plus de 5 travaux en niveau d'avertissement
    # supérieur à 4 (:greater_than_four) il faut avertir
    # l'administration
    if avertissement[:greater_than_four] > 4
      Unan::rapport_admin.depassements.merge!(
        auteur.id => "#{auteur.pseudo} (##{auteur.id}) est en sur-dépassement (nombre de travaux en avertissement supérieur à 4 : #{avertissement[:greater_than_four]})."
      )
    end

  rescue Exception => e
    error e.message
  else
    true
  end

end #/StarterPDay
end #/Program
end #/Unan
