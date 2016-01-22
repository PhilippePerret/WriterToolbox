# encoding: UTF-8
=begin

Instance d'un gel en particulier

=end
require 'fileutils'
class SiteHtml
class Gel

  # Nom du gel, i.e. nom du dossier contenant ses éléments
  attr_reader :name

  def initialize gel_name
    @name = gel_name
  end

  # ---------------------------------------------------------------------
  # Les deux méthodes de gel principales
  #
  # +options+ Pour le moment, inutilisé
  # RETURN True (principalement pour la console)
  def gel options = nil
    folder.remove if exist?
    FileUtils::cp_r site.folder_db.to_s , folder.to_s
    true
  end
  # RETURN True (principalement pour la console) si tout s'est
  # bien passé, false otherwise
  def degel options = nil
    if exist?
      backup_and_delete_current_folder_data
      FileUtils::cp_r folder.to_s, site.folder_database.to_s
      true
    else
      error "Le gel `#{name}` n'existe pas."
    end
  end
  #
  # ---------------------------------------------------------------------

  def backup_and_delete_current_folder_data
    FileUtils::cp_r   site.folder_db.to_s, folder_backup
    FileUtils::rm_rf  site.folder_db.to_s
  end

  def exist?
    folder.exist?
  end

  def folder_backup
    @folder_backup ||= (self.class::folder + '__backup__').to_s
  end

  # {SuperFile} Dossier contenant les éléments du gel
  def folder
    @folder ||= self.class::folder + name
  end

end #/Gel
end #/SiteHtml
