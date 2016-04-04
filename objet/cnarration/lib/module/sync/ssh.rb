# encoding: UTF-8
=begin
Méthodes SSH pour la synchronisation de la collection
=end
class SynchroNarration
class << self

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
  def serveur_ssh_icare
    @serveur_ssh_icare ||= "icare@ssh-icare.alwaysdata.net"
  end

end #/<< self
end #/SynchroNarration
