# encoding: UTF-8
=begin

Méthodes de path

=end
class Unan
class Program
  # {SuperFile} Path à la base de donnée du programme courant
  def database_path
    @database_path ||= folder + "program#{id}.db"
  end

  def folder
    @folder ||= site.folder_db + "unan/user/#{auteur_id}"
  end
end #/Program
end #/Unan
