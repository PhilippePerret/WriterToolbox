# encoding: UTF-8
class Cnarration
class Page

  include MethodesObjetsBdD

  attr_reader :id

  def initialize page_id = nil # pour l'édition
    @id = page_id
  end

  # Si le fichier n'existe pas (ce qui peut arriver) et que c'est
  # l'administrateur qui visite, on le crée.
  def create_page
    return unless user.admin?
    return if path.exist?
    (path.write "<!-- Page: ##{id} #{titre} -->\n\n")
  end

  def table
    @table ||= Cnarration::table_pages
  end

end #/Page
end #/Cnarration
