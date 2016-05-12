# encoding: UTF-8
=begin

  Pour tester une route, c'est-à-dire une page

  Ce sont les méthodes fonctionnelles. Pour voir les méthods
  utilisables dans les tests, cf. le module `test_methods.rb`

=end
class SiteHtml
class Test
class Route

  attr_reader :raw_route

  # +raw_route+ La route brut, qui peut contenir un query_string
  def initialize raw_route
    @raw_route = raw_route
  end

  def url
    @url ||= "#{SiteHtml::Test::base_url}/#{raw_route}"
  end

  def request req
    SiteHtml::Test::Request::new(nil, req).execute
  end
  def request_only_header
    @request_only_header  ||= "curl -I #{url}"
  end
  def request_whole_page
    @request_whote_page   ||= "curl #{url}"
  end

  def code_page
    @code_page ||= request(request_whole_page).content
  end

end #/Route
end #/Test
end #/SiteHtml
