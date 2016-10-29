# encoding: UTF-8
class Cnarration
class Page

  include MethodesMySQL

  attr_reader :id

  def initialize page_id = nil # pour l'édition
    @id = page_id
  end

  # Si le fichier n'existe pas (ce qui peut arriver) et que c'est
  # l'administrateur qui visite, on le crée.
  def create_page
    user.admin?           || return
    false == path.exist?  || return
    (path.write "<!-- Page: ##{id} #{titre} -->\n\n")
  end

  def table
    @table ||= Cnarration.table_pages
  end

end #/Page
end #/Cnarration
