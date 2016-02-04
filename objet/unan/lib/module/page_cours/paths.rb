# encoding: UTF-8
class Unan
class Program
class PageCours

  # Path de la page originale (celle dont on travaille le contenu)
  def fullpath
    @fullpath ||= folder_pages_originales + "#{type}/#{path}"
  end
  # Path de la page semi-dynmaique (celle dont on a corrigé les
  # principaux textes fixes — balises — pour ne laisser que les
  # textes dynamiques). C'est cette page qui contient le code
  # template qui sera détemplatisé et envoyé au lecteur.
  def fullpath_semidyn
    @fullpath_semidyn ||= begin
      sf = folder_pages_semidynamiques + "#{type}/#{path}"
      sf.dirname.build unless sf.dirname.exist?
      sf
    end
  end
  def fullpath_backup
    @fullpath_backup ||= begin
      dirname + "#{affixe}-backup#{NOW}.#{extension}"
    end
  end

  def dirname
    @dirname ||= fullpath.dirname
  end
  def dirname_semidyn
    @dirname_semidyn ||= begin
      d = fullpath_semidyn.dirname
      d.build unless d.exist?
      d
    end
  end
  def affixe
    @affixe ||= fullpath.affixe
  end
  def extension
    @extension ||= fullpath.extension
  end

  def folder_pages_originales
    @folder_pages_originales ||= Unan::main_folder_data + "pages_cours"
  end
  def folder_pages_semidynamiques
    @folder_pages_semidynamiques ||= begin
      d = Unan::main_folder_data + "pages_semidyn"
    end
  end

end #/PageCours
end #/Program
end #/UnanAdmin
