# encoding: UTF-8
class Sync

  # {Array} Liste de messages de suivi d'opération
  attr_reader :suivi

  # Retourne le code de l'état des lieux des synchros
  # à afficher dans la page.
  #
  # La méthode est appelée aussi bien ONLINE que OFFLINE.
  # En ONLINE, elle retourne l'état de synchro (cf. la méthode
  # etat_des_lieux_online).
  # En OFFLINE, elle affiche cet état des lieux.
  #
  # Il prend les données de FILES2SYNC pour définir les fichiers
  # à checker.
  #
  def etat_des_lieux
    @suivi ||= Array::new
    if ONLINE
      etat_des_lieux_online
    else
      etat_des_lieux_offline
    end
  end

  # Méthode qui détruit tous les fichiers provisoires (pour
  # forcer le check)
  def reset_all
    folder_tmp.remove
    folder_tmp.build unless folder_tmp.exist?
  end

end #/Sync
