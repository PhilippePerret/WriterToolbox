# encoding: UTF-8
class SiteHtml
class TestSuite

  def verbose?  ; self.class::options[:verbose]       end
  def quiet?    ; self.class::options[:quiet]         end
  def debug?    ; self.class::options[:debug] == true end
  def online?   ; options[:online] == true            end
  def offline?  ; options[:offline] == true           end

end #/TestSuite
end #/SiteHtml
