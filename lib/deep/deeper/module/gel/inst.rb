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
    @name = gel_name.strip
  end

  # ---------------------------------------------------------------------
  # Les deux méthodes de gel principales
  #
  # +options+ Pour le moment, inutilisé
  # RETURN True (principalement pour la console)
  def gel options = nil
    return false if name_invalide?
    folder.remove if exist?
    FileUtils::cp_r site.folder_db.to_s , folder.to_s
    true
  end
  # RETURN True (principalement pour la console) si tout s'est
  # bien passé, false otherwise
  def degel options = nil
    return false if name_invalide?
    if exist?
      backup_and_delete_current_folder_data
      FileUtils::cp_r folder.to_s, site.folder_database.to_s
      # Pour le moment, le dossier gel porte dans ./database le nom
      # du gel. Il faut lui remettre le nom 'data'
      as_folder_database.rename 'data'
      true
    else
      error "Le gel `#{name}` n'existe pas."
      false
    end
  end
  #
  # ---------------------------------------------------------------------

  def name_invalide?
    raise "Il faut préciser le nom du gel." if name.empty?
    debug "name = '#{name}'"
    raise "`__backup__` est un nom réservé." if name == "__backup__"
    raise "Les noms ne peuvent pas contenir d'espaces." if name.match(/ /)
    not_ok = name.gsub(/[a-zA-Z0-9_\.\-]/,'') != ""
    raise "Les noms ne peuvent contenir que a-z, A-Z, 0-9, `_`, `.` et -" if not_ok
  rescue Exception => e
    error e
    true # Not OK
  else
    false # OK
  end
  def backup_and_delete_current_folder_data
    as_folder_backup.remove if as_folder_backup.exist?
    FileUtils::cp_r   site.folder_db.to_s, as_folder_backup.to_s
    FileUtils::rm_rf  site.folder_db.to_s
  end

  def exist?
    folder.exist?
  end

  # Le chemin du dossier data/backup
  def as_folder_backup
    @as_folder_backup ||= (self.class::folder + '__backup__')
  end

  # Le path du dossier quand il se trouve copié du dossier des gels
  # vers le dossier database. Il porte son nom de gel et il faudra
  # lui donner le nom 'data'
  def as_folder_database
    @as_folder_database ||= site.folder_database + name
  end

  def path_as_folder_gel

  end

  # {SuperFile} Dossier contenant les éléments du gel
  def folder
    @folder ||= self.class::folder + name
  end

end #/Gel
end #/SiteHtml
