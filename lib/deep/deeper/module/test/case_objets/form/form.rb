# encoding: UTF-8
class SiteHtml
class TestSuite
class Form

  # Les méthodes propres à tous les objets-case
  include ModuleObjetCaseMethods

  # {Hash} Les données pour le formulaire
  attr_reader :data_form

  def initialize route, data = nil
    @raw_route  = route
    @data_form  = data
  end


end #/Form
end #/TestSuite
end #/SiteHtml
