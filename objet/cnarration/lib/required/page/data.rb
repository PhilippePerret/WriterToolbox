# encoding: UTF-8
class Cnarration
class Page

  def titre     ; @titre      ||= get(:titre)     end
  def options   ; @options    ||= get(:options)   end
  def livre_id  ; @livre_id   ||= get(:livre_id)  end
  def handler   ; @handler    ||= get(:handler)   end

  # ---------------------------------------------------------------------
  #   Données volatiles
  # ---------------------------------------------------------------------
  def livre
    @livre ||= Cnarration::Livre::get(livre_id)
  end

  # Contenu du fichier d'origine
  def content
    @content ||= path.read
  end

  def path
    @path ||= begin
      p = site.folder_data+"unan/pages_cours/#{handler}.erb"
      p.folder.build unless p.folder.exist?
      p
    end
  end
  def fullpath; @fullpath ||= File.expand_path(path.to_s) end

  def path_semidyn
    @path_semidyn ||= begin
      p = site.folder_data+"unan/pages_semidyn/#{handler}.erb"
      p.folder.build unless p.folder.exist?
      p
    end
  end
  def fullpath_semidyn ; @fullpath_semidyn ||= File.expand_path(path_semidyn.to_s) end

end #/Page
end #/Cnarration
