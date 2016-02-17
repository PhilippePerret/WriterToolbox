# encoding: UTF-8
class Cnarration
class Page

  include MethodesObjetsBdD

  attr_reader :id

  def initialize page_id = nil # pour l'édition
    @id = page_id
  end

  def table
    @table ||= Cnarration::table_pages
  end

end #/Page
end #/Cnarration
