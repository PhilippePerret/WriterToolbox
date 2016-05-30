# encoding: UTF-8
=begin

  Class Sync::Database
  --------------------
  Pour la gestion générale des fichiers database distants et
  locaux.

=end
# site.require_module 'remote_file'

class Sync
class Database

  # ---------------------------------------------------------------------
  #   Classe
  # ---------------------------------------------------------------------
  class << self


    def init
      site.require_module 'remote_file'
    end

    # La base site_cold.db
    #
    # À l'instanciation de cette variable, on downloade
    # aussi la base distante en l'enregistrant avec un nom
    # provisoire ici pour ne pas écraser la base existante.
    def site_cold
      @site_cold ||= begin
        sdb = new('site_cold.db')
        sdb.download
        sdb
      end
    end

  end #/<< self

  # ---------------------------------------------------------------------
  #     Instance
  # ---------------------------------------------------------------------
  attr_reader :name

  # NIL ou true. Mis à true par les méthodes qui synchronise
  # les tables de la base de données en question.
  attr_accessor :need_upload

  # +name+  Le nom. En fait, le chemin relatif depuis ./database/data, mais
  # toutes les bases sont en racine, normalement.
  def initialize name # par exemple 'site_cold.db'
    name.end_with?('.db') || name += ".db"
    @name = name
  end

  # On download le fichier distant mais sans écraser le
  # fichier local.
  def download
    File.unlink dst_loc_path if File.exist?(dst_loc_path)
    rfile.download
    size = File.stat(dst_loc_path).size
    debug "TAILLE DE LA BASE site_cold après download : #{size}"
    size > 0 || raise( "La taille de site_cold.db ne devrait pas être de ZÉRO.")
  end

  # Upload la base de données si nécessaire
  # (et détruit le fichier distant provisoire)
  def upload_if_needed
    debug "-> Sync::Database#upload_if_needed"
    File.unlink( dst_loc_path ) if File.exist?( dst_loc_path )
    need_upload || return
    upload
  end

  # On upload le fichier local
  def upload
    debug "-> upload #{loc_path}"
    rfile.upload
  end

  # Le remote-file de la base de données
  #
  # En définissant l'instance, on affecte aussi son nouveau
  # nom provisoire en local pour que le download n'écrase
  # pas le fichier local afin que les synchros puissent se
  # faire
  def rfile
    @rfile ||= begin
      defined?(RFile) || self.class.init
      rf = RFile::new(loc_path)
      rf.distant.downloaded_file_name = dst_loc_name
      rf
    end
  end

  # L'affixe
  def affixe
    @affixe ||= File.basename(name, File.extname(name))
  end

  # Le chemin d'accès local
  def loc_path
    @loc_path ||= File.join('.', 'database', 'data', name)
  end

  # Le nom du download du fichier distant
  def dst_loc_name
    @dst_loc_name ||= "#{affixe}-distant-prov.db"
  end
  # Le path du download du fichier distant provisoire
  def dst_loc_path
    @dst_loc_path ||= File.join('.', 'database', 'data', dst_loc_name)
  end

end #/Database
end #/Sync
