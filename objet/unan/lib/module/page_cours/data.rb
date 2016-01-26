# encoding: UTF-8
class Unan
class Program
class PageCours

  include MethodesObjetsBdD

  # ID de la page de cours
  attr_reader :id

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------

  def id        ; @id       ||= get_id        end
  def handler   ; @handler  ||= get(:handler) end
  def titre     ; @titre    ||= get(:titre)   end
  def path      ; @path     ||= get(:path)    end
  def type      ; @type     ||= get(:type)    end

  # ---------------------------------------------------------------------
  #   Data volatile de la page
  # ---------------------------------------------------------------------

  def extension
    @extension ||= File.extname(path)[1..-1]
  end
  def fullpath
    @fullpath ||= Unan::main_folder_data + "pages_cours/#{type}/#{path}"
  end


end #/PageCours
end #/Program
end #/Unan
