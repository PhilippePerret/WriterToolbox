# encoding: UTF-8
=begin

  Pour tester une route, c'est-à-dire une page

  Ce sont les méthodes fonctionnelles. Pour voir les méthods
  utilisables dans les tests, cf. le module `test_methods.rb`

=end

class SiteHtml
class TestSuite
class Route

  include ModuleObjetCaseMethods
  
  include ModuleRouteMethods

  attr_reader :raw_route

  # +raw_route+ La route brut, qui peut contenir un query_string
  def initialize raw_route
    @raw_route = raw_route
  end


end #/Route
end #/TestSuite
end #/SiteHtml
