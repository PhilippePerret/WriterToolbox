# encoding: UTF-8
=begin

Méthods de path pour Unan

=end
class Unan
class << self

  # "./data/unan/data"
  def folder_data
    @folder_data ||= main_folder_data + 'data'
  end
  # Le dossier principal "./data/unan"
  def main_folder_data
    @main_folder_data ||= site.folder_data + 'unan'
  end
  def folder_modules
    @folder_modules ||= folder_lib + 'module'
  end
  alias :folder_module :folder_modules
  # ---------------------------------------------------------------------
  def folder_lib
    @folder_lib ||= folder + 'lib'
  end
  # ---------------------------------------------------------------------
  def folder
    @folder ||= site.folder_objet + 'unan'
  end

end # << self
end # /Unan
