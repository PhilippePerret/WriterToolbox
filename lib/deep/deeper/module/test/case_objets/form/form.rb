# encoding: UTF-8
class SiteHtml
class TestSuite
class Form

  # Les méthodes propres à tous les objets-case
  include ModuleObjetCaseMethods

  # Les méthodes propres aux routes (dès que l'objet-case
  # doit interagir avec la page)
  include ModuleRouteMethods

  # {String} La route pour rejoindre le formulaire
  attr_reader :route

  # {Hash} Les données pour le formulaire
  attr_reader :data

  def initialize route, data
    @route  = route
    @data   = data
  end


end #/Form
end #/TestSuite
end #/SiteHtml
