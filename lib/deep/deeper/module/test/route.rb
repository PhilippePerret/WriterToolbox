# encoding: UTF-8
=begin

Pour tester une route, c'est-à-dire une page

=end
class SiteHtml
class Test
class Route

  # +raw_route+ La route brut, qui peut contenir un query_string
  def initialize raw_route
    @raw_route = raw_route
  end

  def respond
    return true
  end

  def has_title titre, niveau_titre = nil
    return true
  end

end #/Route
end #/Test
end #/SiteHtml
