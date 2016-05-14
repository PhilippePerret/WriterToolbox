# encoding: UTF-8
class SiteHtml
class TestSuite
class TestForm < DSLTestClass

  attr_reader :data_form

  def initialize raw_route, data_form=nil, options=nil, &block
    @raw_route = raw_route
    @data_form = data_form
    super(&block)
  end


end #/TestForm
end #/TestSuite
end #/SiteHtml
