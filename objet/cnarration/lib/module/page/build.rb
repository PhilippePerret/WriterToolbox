# encoding: UTF-8
=begin
Constructeur d'une page .str vers la page semi-dynamique qui sera
affichée sur le site.

Pour la construire, on se sert du module de la collection version MD.
=end

site.require_deeper_gem "kramdown-1.9.0"

class Cnarration
class Page

  def build
    path_semidyn.remove if path_semidyn.exist?
    path_semidyn.write html_code
  end

  def original_code
    @original_code ||= path.read
  end

  def html_code
    Kramdown::Document.new(original_code).to_html
  end

  def latex_code
    Kramdown::Document.new(original_code).to_latex
  end


end #/Page
end #/Cnarration
