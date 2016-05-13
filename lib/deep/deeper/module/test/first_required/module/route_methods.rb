# encoding: UTF-8
=begin

Module contenant les méthodes pour les routes, utile par exemple aux
tests des pages (des routes) et des formulaires.

REQUIS

  L'objet-case qui utilise ces méthodes doit impérativement définir :

    - raw_route     Variable d'instance contenant la route entière
                    même avec son query-string.

=end
module ModuleRouteMethods

  require 'nokogiri'
  require 'open-uri'

  # {String} La route pour rejoindre le formulaire
  attr_reader :raw_route

  # RETURN Une instance SiteHtml::TestSuite::Html qui permettra
  # de faire tous les tests sur le code HTML avec Nokogiri
  def instance_test_html
    @instance_test_html ||= SiteHtml::TestSuite::Html::new(nokogiri_page)
  end


  # Produit un succès si la route retourne une page 200,
  # produit une failure dans le cas contraire.
  #
  def responds options = nil, inverse = false
    SiteHtml::TestSuite::Case::new(
      result:         request(request_only_header).ok?,
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

  def url
    @url ||= "#{SiteHtml::TestSuite::current::base_url}/#{raw_route}"
  end

  def request req
    SiteHtml::TestSuite::Request::new(nil, req).execute
  end
  def request_only_header
    @request_only_header  ||= "curl -I #{url}"
  end
  def request_whole_page
    @request_whote_page   ||= "curl #{url}"
  end

  def code_page
    @code_page ||= begin
      request(request_whole_page).content
    end
  end

  def nokogiri_page
    @nokogiri_page ||= Nokogiri::HTML( open url )
  end

end
