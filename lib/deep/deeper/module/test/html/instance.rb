# encoding: UTF-8
=begin

SiteHtml::Test::Html

Pour le traitement des codes Html

=end
class SiteHtml
class TestSuite
class Html

  # {String} Le code tel qu'il est soumis à l'instanciation
  attr_reader :raw_code

   # {Nokogiri::HTML::Document}
  # Utiliser `page` plutôt
  attr_reader :nokogiri_html_doc

  # Argument : Soit du code HTML brut, soit (meilleur) un
  # Nokogiri::HTML::Document
  def initialize rawhtml_or_nokohtml
    @nokogiri_html_doc = case rawhtml_or_nokohtml
    when Nokogiri::HTML::Document
      rawhtml_or_nokohtml
    when String
      @raw_code = rawhtml_or_nokohtml
      Nokogiri::HTML(rawhtml_or_nokohtml)
    else
      raise "Mauvais format pour l'instanciation de SiteHtml::Test::Html : #{rawhtml_or_nokohtml.class} (String ou Nokogiri::HTML::Document attendu)"
    end
  end

  # Raccourci
  def page ; @nokogiri_html_doc end


end #/Html
end #/TestSuite
end #/SiteHtml
