# encoding: UTF-8
class Cnarration
class Latex
class << self

  # Préparation du dossier Latex principal dans les
  # dossiers temporaires.
  #
  # On copie dans ce dossier tous les éléments du dossier
  # assets qui seront utiles à tous les livres.
  #
  # On produit si nécessaire, avant la copie, les bibliographies
  # utiles, comme la filmographie
  def init_latex_folder

    # S'il faut actualiser le fichier filmographie, il faut
    # le faire
    Cnarration::Filmography::build_if_needed

    # On peut ensuite construire le dossier principal en
    # y copiant tous les fichiers
    fassets = Cnarration::Translator::folder + "assets"
    FileUtils::cp_r "#{fassets.to_s}/.", "#{tmp_latex_folder}/"
    # Il faut détruire le fichier READ_ME qui sert pour le
    # dossier asset mais pas pour les livres exportés
    (tmp_latex_folder+'_read_me_.md').remove
  end

  # Dossier Latex temporaire principal
  def tmp_latex_folder
    @tmp_latex_folder ||= begin
      d = site.folder_tmp+"latex"
      d.remove if d.exist?
      d
    end
  end

end # /<< self
end #/Latex
end #/Cnarration
