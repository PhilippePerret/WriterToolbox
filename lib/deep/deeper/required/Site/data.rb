# encoding: UTF-8
=begin
Class SiteHtml
--------------
Méthodes de données
=end
class SiteHtml

  # Pour le moment, placé ici, mais plus tard, il faudra le mettre
  # plus à disposition, dans un fichier de configuration du site  
  def title
    @title ||= "LA BOITE À OUTILS DE L'AUTEUR (WRITER'S TOOLBOX)"
  end
  def base; @base ||= "http://localhost/WriterToolbox/" end

end
