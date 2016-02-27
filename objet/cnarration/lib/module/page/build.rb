# encoding: UTF-8
=begin
Constructeur d'une page .str vers la page semi-dynamique qui sera
affichée sur le site.

Pour la construire, on se sert du module de la collection version MD.
=end

# Requérir l'extension SuperFile qui va ajouter les méthodes
# de traitement des fichiers Markdown.
site.require_module 'kramdown'


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
