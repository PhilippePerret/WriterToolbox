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

  def id          ; @id           ||= get_id            end
  def handler     ; @handler      ||= get(:handler)     end
  def titre       ; @titre        ||= get(:titre)       end
  def description ; @description  ||= get(:description) end
  def path        ; @path         ||= get(:path)        end
  def type        ; @type         ||= get(:type)        end

  # ---------------------------------------------------------------------
  #   Data volatile de la page
  # ---------------------------------------------------------------------

  # def extension
  #   @extension ||= File.extname(path)[1..-1]
  # end
  # def fullpath
  #   @fullpath ||= Unan::main_folder_data + "pages_cours/#{type}/#{path}"
  # end

  # Retourne l'instance User::UPage de l'auteur pour cette page
  # +auteur+ Instance User de l'auteur, par défaut user courant.
  def upage auteur = nil
    auteur ||= user
    User::UPage::get(auteur, self.id)
  end


end #/PageCours
end #/Program
end #/Unan
