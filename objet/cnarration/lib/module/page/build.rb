# encoding: UTF-8
=begin
Constructeur d'une page .str vers la page semi-dynamique qui sera
affichée sur le site.

Pour la construire, on se sert du module de la collection version MD.
=end

# Requérir l'extension SuperFile qui va ajouter les méthodes
# de traitement des fichiers Markdown.
site.require_module 'kramdown'

class SuperFile
  # Traitement particulier des images dans
  def formate_balises_images_in code
    code.gsub(/IMAGE\[(.*?)(?:\|(.*?))?\]/){
      imgpath = imgpath_init = $1.to_s
      debug "imgpath: '#{imgpath}'"
      imgpath += ".png" if File.extname(imgpath) == ""
      imgpath = seek_image_path_of(imgpath)
      debug "imgpath: '#{imgpath}'"
      titalt  = $2.gsub(/'/, "’") unless titalt.nil?
      if imgpath != nil
        "<center><img src='#{imgpath}' alt='Image: #{titalt}' /></center>"
      else
        "IMAGE MANQUANTE: #{imgpath_init}"
      end
    }
  end

  # Cf. aide
  def seek_image_path_of prelimg
    in_img_book = path_image_in_folder_img_book prelimg
    return in_img_book.to_s if in_img_book.exist?
    in_img_collection = path_image_in_folder_img_narration prelimg
    return in_img_collection if in_img_collection.exist?
    in_img_site = path_image_in_folder_img_site prelimg
    return in_img_site if in_img_site.exist?
    nil
  end
  def path_image_in_folder_img_book prelimg
    folder_narration = "./data/unan/pages_cours/cnarration/"
    rel_folder = (folder - folder_narration).to_s
    rel_folder = rel_folder.split("/")
    livre = rel_folder.shift
    rel_folder = File.join(rel_folder)
    folder_images = File.join("./data/unan/pages_semidyn/cnarration/", livre, 'img')
    SuperFile::new([folder_images, rel_folder, prelimg])
  end
  def path_image_in_folder_img_narration prelimg
    SuperFile::new(["./data/unan/pages_semidyn/cnarration/img", prelimg])
  end
  def path_image_in_folder_img_site prelimg
    site.folder_images + prelimg
  end

end #/String

class Cnarration
class Page

  # Construit la page semi-dynamique
  def build options = nil
    options ||= Hash::new
    options[:format] ||= :erb # peut être aussi :latex
    path_semidyn.remove if path_semidyn.exist?
    create_page unless path.exist?
    path.kramdown(in_file: path_semidyn.to_s, output_format: options[:format])
    flash "Page actualisée."
  end

end #/Page
end #/Cnarration
