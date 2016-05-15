# encoding: UTF-8
class SiteHtml
class TestSuite
class TestForm < DSLTestClass

  attr_reader :data_form

  def initialize tfile, raw_route, data_form=nil, options=nil, &block
    @raw_route = raw_route
    @data_form = data_form
    super(tfile, &block)
  end

  def description_defaut
    @description_defaut ||= begin
      form_specs = if data_form[:id]
        " ##{data_form[:id]}"
      elsif data_form[:name]
        " .#{data_form[:name]}"
      else
        ""
      end
      "TEST FORM#{form_specs} AT #{url}"
    end
  end

end #/TestForm
end #/TestSuite
end #/SiteHtml
