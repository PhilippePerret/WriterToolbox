# encoding: UTF-8
class Cnarration
class Page

  def relative_affixe
    @relative_affixe ||= "#{livre_folder}/#{handler}"
  end
  def livre_folder
    @livre_folder ||= Cnarration::LIVRES[livre_id][:folder]
  end
  def path
    @path ||= begin
      p = site.folder_data+"unan/pages_cours/cnarration/#{relative_affixe}.md"
      p.folder.build unless p.folder.exist?
      p
    end
  end
  def fullpath; @fullpath ||= File.expand_path(path.to_s) end

  def path_semidyn
    @path_semidyn ||= begin
      p = site.folder_data+"unan/pages_semidyn/cnarration/#{relative_affixe}.erb"
      p.folder.build unless p.folder.exist?
      p
    end
  end
  def fullpath_semidyn ; @fullpath_semidyn ||= File.expand_path(path_semidyn.to_s) end

end #/Page
end #/Cnarration
