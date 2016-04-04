# encoding: UTF-8
class SynchroNarration
class << self

  # {SuperFile} SuperFile du fichier local qui doit être
  # synchronisé
  # Note : On peut employer le terme plus explicite `base_local_path`
  def path_local
    @path_local ||= SuperFile::new('./database/data/cnarration.db')
  end
  alias :base_local_path :path_local

  # {SuperFile} SuperFile du fichier BOA distant qui a
  # été rappatrié du serveur
  def distant_local_path
    @path_distant ||= SuperFile::new('./database/data/cnarration-distant.db')
  end

  # Path du fichier base distant sur Boa
  # Note : Pour SSH
  def base_distant_path_boa
    @base_distant_path_boa ||= "./www/database/data/cnarration.db"
  end

  # Path du fichier base distant sur Icare
  # Note : Pour SSH
  def base_distant_path_icare
    @base_distant_path_icare ||= "./www/storage/narration/cnarration.db"
  end

end #/<< self
end #/SynchroNarration
