# encoding: UTF-8
class SiteHtml
class TestSuite

  attr_reader :options


  def parse_options
    @options ||= Hash::new
    @options.merge!(debug: false) unless @options.has_key?(:debug)
    debug "SiteHtml::Test::options : #{@options.pretty_inspect}"
    self.class::options = @options.delete(:options)
  end


end #/TestSuite
end #/SiteHtml
