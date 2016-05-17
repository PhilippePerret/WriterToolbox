# encoding: UTF-8
=begin

  Pour tester une route, c'est-à-dire une page

  Ce sont les méthodes fonctionnelles. Pour voir les méthods
  utilisables dans les tests, cf. le module `test_methods.rb`

=end

class SiteHtml
class TestSuite
class TestRoute < DSLTestMethod

  # attr_reader :raw_route

  # +raw_route+ La route brut, qui peut contenir un query_string
  def initialize tfile, raw_route, options=nil, &block
    @raw_route = raw_route
    super(tfile, &block)
  end

  def description_defaut
    @description_defaut ||= "TEST ROUTE #{clickable_url}"
  end

end #/Route
end #/TestSuite
end #/SiteHtml
