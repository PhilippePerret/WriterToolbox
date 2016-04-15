# encoding: UTF-8
class Cnarration
class Livre

  # Méthodes spéciales pour l'export latex ajoutées à la
  # class Cnarration::Livre

  
  # {Cnarration::LatexMainFile} Instance du fichier main latex
  def latex_main_file
    @latex_main_file ||= begin
      Cnarration::LatexMainFile::new(self)
    end
  end

  # Préparation du dossier Latex principal dans les
  # dossiers temporaires.
  # On copie dans ce dossier tous les éléments du dossier
  # assets qui seront utiles à tous les livres.
  def init_latex_folder
    latex_folder.build
    fassets = Cnarration::folder+"lib/module/latex/assets/."
    FileUtils::cp_r fassets.to_s, "#{latex_folder.folder}/"
    # Il faut détruire le fichier READ_ME qui sert pour le
    # dossier asset mais pas pour les livres exportés
    (latex_folder.folder+'_read_me_.md').remove
  end

  def latex_source_folder
    @latex_source_folder ||= begin
      d = latex_folder+'sources'
      d.remove if d.exist?
      d
    end
  end
  def latex_folder
    @latex_folder ||= tmp_latex_folder+"BOOK_#{folder_name.upcase}"
  end
  def tmp_latex_folder
    @tmp_latex_folder ||= begin
      d = site.folder_tmp+"latex"
      d.remove if d.exist?
      d
    end
  end

end #/Livre
end #/Cnarration
