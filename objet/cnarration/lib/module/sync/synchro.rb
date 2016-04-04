# encoding: UTF-8
class SynchroNarration
class << self

  # Méthode appelée par le tableau de bord de la synchronisation
  # générale pour synchroniser la collection Narration aussi bien
  # sur BOA distant que sur Narration
  #
  # +force_online+ Si true, on ne vérifie pas les
  # niveau de développement online, on uploade la base
  # telle quelle sur BOA et sur Icare.
  def synchronize_all force_online = false
    @suivi = Array::new

    @suivi << (force_online ? "Synchronisation forcée" : "Synchronisation intelligente")

    unless force_online
      # On rappatrie la base cnarration.db du site distant
      # BOA vers local en lui donnant le nom `cnarration-distant.db`
      # pour ne pas qu'elle écrase la base existante
      download_distant_base
      # On ajuste les données au niveau du niveau de développement
      synchronise_statuts_of_pages
    end

    # On peut uploader la base du BOA et sur Icare
    # TODO: Pour le moment, c'est court-circuité sur Icare
    @suivi << "* Upload de la base cnarration.db"
    upload_base

  rescue Exception => e
    debug e
    @suivi << "ERROR : #{e.message}"
    return false
  else
    return true
  end


  # ---------------------------------------------------------------------
  #   Méthodes d'upload/download
  # ---------------------------------------------------------------------

  def upload_base
    upload_base_on_boa
    upload_base_on_icare
  end
  # Charger le fichier BOA distant
  def download_distant_base
    distant_local_path.remove if distant_local_path.exist?
    cmd = "scp -p #{serveur_ssh_boa}:#{base_distant_path_boa} #{distant_local_path.expanded_path}"
    res = `#{cmd}`
    if distant_local_path.exist?
      @suivi << "Download du fichier cnarration.db distant OK"
    else
      raise "Impossible de ramener le fichier cnarration.db distant… (#{res.inspect})"
    end
  end

  # Upload de la base sur BOA
  def upload_base_on_boa
    cmd = "scp -p #{base_local_path.expanded_path} #{serveur_ssh_boa}:#{base_distant_path_boa}"
    res = `#{cmd}`
  end
  def upload_base_on_icare
    return
    raise "Pour le moment, il ne faut pas le faire, les deux bases ne sont pas construites pareil."
    cmd = "scp -p #{base_local_path.expanded_path} #{serveur_ssh_icare}:#{base_distant_path_icare}"
    res = `#{cmd}`
  end


end #/<< self
end #/SynchroNarration
