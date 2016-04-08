# encoding: UTF-8
=begin
Méthodes SSH pour la synchronisation de la collection
=end
class SynchroAnalyse

  # ---------------------------------------------------------------------
  #   Méthodes d'upload/download
  # ---------------------------------------------------------------------

  def upload_base
    upload_base_on_boa
  end
  # Charger le fichier BOA distant
  def download_distant_base
    distant_local_path.remove if distant_local_path.exist?
    cmd = "scp -p #{serveur_ssh_boa}:#{base_distant_path_boa} #{distant_local_path.expanded_path}"
    res = `#{cmd}`
    if distant_local_path.exist?
      @suivi << "Download du fichier analyse.db distant OK"
    else
      raise "Impossible de ramener le fichier analyse.db distant… (#{res.inspect})"
    end
  end

  # Upload de la base sur BOA
  def upload_base_on_boa
    cmd = "scp -p #{base_local_path.expanded_path} #{serveur_ssh_boa}:#{base_distant_path_boa}"
    res = `#{cmd}`
  end

  # ---------------------------------------------------------------------
  #   Serveurs
  # ---------------------------------------------------------------------

  # Adresse du serveur SSH sous la forme "<user>@<adresse ssh>"
  # Note : Défini dans './objet/site/data_synchro.rb'
  def serveur_ssh
    @serveur_ssh ||= begin
      require './objet/site/data_synchro.rb'
      Synchro::new().serveur_ssh
    end
  end
  alias :serveur_ssh_boa :serveur_ssh

  # Serveur Icare
  # (ne sert pas pour cette synchro mais on ne sait jamais…)
  def serveur_ssh_icare
    @serveur_ssh_icare ||= "icare@ssh-icare.alwaysdata.net"
  end

end #/SynchroNarration
