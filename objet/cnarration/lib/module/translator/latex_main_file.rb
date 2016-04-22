# encoding: UTF-8
class Cnarration
class LatexMainFile

  # {Cnarration::Livre} Livre de ce main-file latex
  attr_reader :livre

  def initialize ilivre
    @livre = ilivre
  end

  # Initialiser le fichier
  def init
    write "% Fichier latex pour le livre “#{livre.titre}”"
    write latex_mark(:document_class)
    write latex_mark(:preambule)
    # Définition du titre du livre
    write "% Titre du livre\n\\newcommand{\\titrelivre}{#{livre.titre}}"
    # Si le livre a un sous-titre, il faut l'indiquer (ils doivent tous
    # en avoir, mais ils ne sont pas encore tous définis)
    if livre.data[:stitre]
      write "% Sous-titre du livre\n\\newcommand{\\soustitrelivre}{#{livre.data[:stitre]}}"
    end
    write latex_mark(:begin_document)
    write latex_mark(:debut_livre)
  end

  # Ferme le fichier latex principal
  # Avant de le fermer, il écrit la bibliographie
  # et la quatrième de couverture grâce au fichier :fin_livre.
  def close
    write latex_mark(:fin_livre)
    write latex_mark(:end_document)
  end

  # Écrire dans le fichier latex principal
  def write str
    sfile.append "#{str}\n"
  end
  def sfile
    @sfile ||= livre.latex_folder + name
  end
  alias :path :sfile

  def name
    @name ||= "#{affixe}.tex"
  end
  def affixe
    @affixe ||= "Livre_#{livre.folder_name}"
  end
  def affixe_path
    @affixe_path ||= (sfile.folder + affixe).expanded_path
  end
  def full_path
    @full_path ||= begin
      debug "sfile.to_s = #{sfile.to_s}"
      fp = sfile.expanded_path
      debug "full path : #{fp}"
      fp
    end
  end


  LATEX_MARKS = {
    document_class:   "\\documentclass[11pt,french,twoside,a5paper,openany]{book}\n% L'option `openany' supprime les pages blanches avant parties (part, chapter)",
    preambule:        "\\input{../commons/preambule.tex}",
    begin_document:   "\\begin{document}",
    # Début commun à tous les livres
    debut_livre:      "\\input{../commons/books_start.tex}",
    fin_livre:        "\\input{../commons/books_end.tex}",
    end_document:     "\\end{document}"
  }
  def latex_mark id
    LATEX_MARKS[id]
  end

end #/LatexMainFile
end #/Cnarration
