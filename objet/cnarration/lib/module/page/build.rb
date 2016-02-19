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

  # Retourne le code original du fichier markdown.
  # Si le fichier n'existe pas (ce qui peut arriver) et que c'est
  # l'administrateur qui visite, on le crée. Dans tous les cas,
  # on retourne un code vide.
  def original_code
    @original_code ||= begin
      if path.exist?
        path.read
      elsif user.admin?
        (path.write "<!-- Page: #{titre} -->")
        "[Fichier créé - Utiliser le lien-bouton “Edit text” pour définir le texte]"
      else
        ""
      end
    end
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
