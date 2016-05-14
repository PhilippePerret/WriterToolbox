# encoding: UTF-8
=begin

  Pour tester une route, c'est-à-dire une page

  Ce sont les méthodes fonctionnelles. Pour voir les méthods
  utilisables dans les tests, cf. le module `test_methods.rb`

=end

class SiteHtml
class TestSuite
class TestRoute < DSLTestClass

  # +raw_route+ La route brut, qui peut contenir un query_string
  def initialize raw_route, options=nil, &block
    @raw_route = raw_route
    super(&block)
  end

  def description_defaut
    @description_defaut ||= "TEST ROUTE #{raw_route}"
  end
  
end #/Route
end #/TestSuite
end #/SiteHtml
