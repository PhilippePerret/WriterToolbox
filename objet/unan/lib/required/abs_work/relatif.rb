# encoding: UTF-8
class Unan
class Program
class AbsWork


  # Des données supplémentaires qu'on peut transmettre à l'instance,
  # qui peuvent servir notamment à l'affichage de la carte du
  # travail.
  #
  # Cette propriété a été ajoutée lorsqu'on ne partait plus de
  # l'instance `Work` d'un travail de l'auteur pour afficher le
  # travail (car cette instance n'existe que lorsque l'auteur
  # a démarré le travail) mais de l'instance AbsWork courante.
  # Mais pour calculer certains temps, comme le temps restant
  # avant d'accomplir le travail, il faut connaitre le début
  # du travail. Cette donnée se trouve dans :relative_data,
  # avec la clé :indice_pday qui définit le jour où le travail
  # a été confié. En le comparant au jour-programme courant,
  # on peut déterminer le nombre de jours restant.
  #
  # Data qu'on peut trouver jusqu'à présent
  #   :user_id              ID de l'auteur du travail
  #   :indice_pday          Indice du jour où le travail a démarré
  #   :indice_current_pday  Indice du jour de travail courant
  attr_accessor :relative_data

  def relatif_auteur
    @relatif_auteur ||= begin
      raise "Impossible de définir l'auteur relatif au travail sans données relative" if relative_data.nil?
      User::get(relative_data[:user_id])
    end
  end

  # Retourne le nombre de jour-programme de différence
  # entre le début du travail et le jour-programme
  # courant
  def relatif_diff_jours
    @relatif_diff_jours ||= begin
      raise "Impossible de calculer la différence de jour sans données relative" if relative_data.nil?
      relative_data[:indice_current_pday] - relative_data[:indice_pday]
    end
  end
  # Retourne true si le travail relatif est terminé
  def relatif_completed?
    raise "Impossible de dire si le travail est achevé sans données relative" if relative_data.nil?
    return false # Pour le moment
  end

  # Retourne TRUE si le travail est en dépassement
  def relatif_depassement?
    @is_relatif_depassement ||= begin
      raise "Impossible de dire si le travail est en dépassement sans données relative" if relative_data.nil?
      relative_data[:indice_pday] + duree < relative_data[:indice_current_pday]
    end
  end

  # Retourne la durée relative en nombre de secondes
  def relatif_duree_relative
    @relatif_duree_relative ||= begin
      raise "Impossible de calculer la durée relative sans données relative" if relative_data.nil?
      duree * relatif_auteur.program.coefficient_duree
    end
  end

  # Timestamp (secondes) du démarrage du travail
  def relatif_started_at
    @relatif_started_at ||= begin
      raise "Impossible de retourner le démarrage du travail sans données relative" if relative_data.nil?
      (NOW - relatif_diff_jours.days) / 1.day
    end
  end

  # Timestamp (secondes) de la fin attendue du travail
  def relative_expected_at
    @relative_expected_at ||= begin
      raise "Impossible de calculer la date de fin du travail sans données relative" if relative_data.nil?
      (relative_data[:indice_pday] + duree).days
    end
  end

end #/AbsWork
end #/Program
end #/Unan
