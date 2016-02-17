# encoding: UTF-8
class Cnarration
class Page

  def titre     ; @titre      ||= get(:titre)     end
  def options   ; @options    ||= get(:options)   end
  def livre_id  ; @livre_id   ||= get(:livre_id)  end
  def handler   ; @handler    ||= get(:handler)   end


  def path
    @path ||= begin
      p = site.folder_data+"unan/pages_cours/#{handler}.erb"
      p.folder.build unless p.folder.exist?
      p
    end
  end

  def path_semidyn
    @path_semidyn ||= begin
      p = site.folder_data+"unan/pages_semidyn/#{handler}.erb"
      p.folder.build unless p.folder.exist?
      p
    end
  end
end #/Page
end #/Cnarration
