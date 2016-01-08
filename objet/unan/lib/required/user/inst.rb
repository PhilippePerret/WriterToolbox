# encoding: UTF-8
class User

  # Création de l'user tout de suite après son
  # inscription/paiement
  def create_for_unan
    folder_data.build unless folder_data.exist?
  end

  # RETURN true si l'user suit le programme Un An Un Script
  # On le sait à partir du moment où il possède un dossier dans
  # ./data/unan/user/
  # NOTE Ce dossier est créé tout de suite après le paiement
  # /inscription au programme
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
