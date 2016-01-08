# encoding: UTF-8
=begin

Méthods de path pour Unan

=end
class Unan
class << self

  def folder_data
    @folder_data ||= folder_lib + 'data'
  end
  def folder_modules
    @folder_modules ||= folder_lib + 'module'
  end
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
