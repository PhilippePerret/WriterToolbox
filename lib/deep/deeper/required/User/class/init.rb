# encoding: UTF-8
=begin

Si un dossier ./objet/user/lib existe, on le charge toujours

=end
class User
  class << self

    def init
      folder_custom_lib.require if folder_custom_lib.exist?
    end

    def folder_custom_lib
      @folder_custom_lib ||= site.folder_objet+'user/lib'
    end
  end#/<< self
end#/User
