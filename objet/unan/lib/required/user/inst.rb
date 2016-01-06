# encoding: UTF-8
class User

  # RETURN true si l'user suit le programme Un An Un Script
  # On le sait à partir du moment où il possède un dossier dans
  # ./data/unan/user/
  def unanunscript?
    folder_data.exist?
  end

  # Le dossier data de l'user dans ./database/data/unan/user/<id>/
  def folder_data
    @folder_data ||= begin
      site.folder_db + "unan/user/#{id}"
    end
  end
end
