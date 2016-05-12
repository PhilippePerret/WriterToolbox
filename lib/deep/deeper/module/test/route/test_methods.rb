# encoding: UTF-8
=begin

  Méthodes de test pour les routes

  @usage

      test_route "la/route" do |r|

        r.<methode>[ <paramètres>]
        r.<methode>[ <paramètres>]
        etc.

      end

=end
class SiteHtml
class TestSuite
class Route

  def responds options = nil, inverse = false
    SiteHtml::TestSuite::Case::new(
      result: request(request_only_header).ok?,
      positif:        !inverse,
      on_success:     "La page existe.",
      on_success_not: "La page n'existe pas (OK).",
      on_failure:     "La page devrait exister.",
      on_failure_not: "La page ne devrait pas exister."
    ).evaluate
  end
  alias :respond :responds
  def not_responds options = nil
    responds options, true
  end

  # Produit un succès si la page contient le tag
  # défini par {String} +tag+ et {hash} +hdata+
  def has_tag tag, hdata = nil
    instance_test_html.has_tag(tag, hdata)
  end

  def has_not_tag tag, hdata = nil
    instance_test_html.has_tag(tag, hdata, inverse = true)
  end

  # Produit un succès si la page contient le titre
  # +titre+ de niveau +niveau_titre+ s'il est fourni.
  # Raise une failure dans le cas contraire
  def has_title titre, niveau = nil, options = nil, inverse = false
    instance_test_html.has_title(titre, niveau, options, inverse)
  end
  def has_not_title titre, niveau = nil, options = nil
    instance_test_html.has_title( titre, niveau, options, true )
  end

  def instance_test_html
    # @instance_test_html ||= SiteHtml::Test::Html::new(code_page)
    @instance_test_html ||= SiteHtml::TestSuite::Html::new(nokogiri_page)
  end

end #/Route
end #/TestSuite
end #/SiteHtml
