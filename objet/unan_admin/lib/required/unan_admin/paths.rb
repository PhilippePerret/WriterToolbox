# encoding: UTF-8
class UnanAdmin
class << self

  def folder_modules
    @folder_modules ||= site.folder_objet + "unan_admin/lib/module"
  end
  
end # << self
end #/UnanAdmin
