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
    path_semidyn.write deprotected_code
    flash "Page actualisée."
  end

  def original_code
    @original_code ||= path.read
  end

  # Retourne le code original où les balises ERB (<% ... %>) ont
  # été remplacée par des marques pour ne pas être parsées. Elles
  # seront ensuite remises pour l'enregistrement du fichier semi-
  # dynamique.
  def erb_protected_code
    @erb_protected_code ||= begin
      original_code.
        gsub(/<\%/, 'ERB-').
        gsub(/\%>/, '-ERB')
    end
  end

  def deprotected_code
    @deprotected_code ||= begin
      html_code.
        gsub(/ERB-/, '<%').
        gsub(/-ERB/, '%>')
    end
  end

  def html_code
    Kramdown::Document.new(erb_protected_code.formate_balises_propres).to_html
  end

  def latex_code
    Kramdown::Document.new(erb_protected_code).to_latex
  end


end #/Page
end #/Cnarration
