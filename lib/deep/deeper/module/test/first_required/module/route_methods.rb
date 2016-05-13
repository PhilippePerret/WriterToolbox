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

  def responds? options = nil
    responds( (options||{}).merge(evaluate: false) )
  end
  def not_responds options = nil
    responds options, true
  end
  # Produit un succès si la route retourne une page 200,
  # produit une failure dans le cas contraire.
  #
  def responds options = nil, inverse = false
    ok = request(request_only_header).ok? # code 200
    unless (options!= nil && options[:evaluate] === false)
      SiteHtml::TestSuite::Case::new(
        result:         ok,
        positif:        !inverse,
        on_success:     "La page existe.",
        on_success_not: "La page n'existe pas (OK).",
        on_failure:     "La page devrait exister.",
        on_failure_not: "La page ne devrait pas exister."
      ).evaluate
    else
      ok
    end
  end
  alias :respond :responds

  # Produit un succès si la page contient le tag
  # défini par {String} +tag+ et {hash} +hdata+
  # Sauf si l'évaluation est mise à false
  def has_tag tag, hdata=nil, inverse=false
    instance_test_html.has_tag(tag, hdata, inverse=false)
  end
  def has_tag? tag, hdata = nil
    instance_test_html.has_tag?(tag, hdata)
  end
  def has_not_tag tag, hdata = nil
    instance_test_html.has_tag(tag, hdata, inverse = true)
  end

  # TEST-CASE
  # Produit un succès si la page contient le titre
  # +titre+ de niveau +niveau_titre+ s'il est fourni.
  # Raise une failure dans le cas contraire
  def has_title titre, niveau = nil, options = nil, inverse = false
    instance_test_html.has_title(titre, niveau, options, inverse)
  end
  # RETURN true ou false
  def has_title? titre, niveau=nil, options=nil, inverse=false
    has_title(titre, niveau, (options||{}).merge(evaluate:false), inverse)
  end
  def has_not_title titre, niveau = nil, options = nil
    instance_test_html.has_title( titre, niveau, options, true )
  end

  # ---------------------------------------------------------------------
  #   Méthodes pour les messages FLASH
  # ---------------------------------------------------------------------

  # TEST-CASE
  def has_message mess, options = nil, inverse = false
    debug "-> ModuleRouteMethods # has_message"
    instance_test_html.has_message( mess, options, inverse )
  end
  # Return TRUE/FALSE
  def has_message? mess, options=nil, inverse=false
    has_message(mess, (options||{}).merge(evaluate: false), inverse)
  end
  # INVERSE
  def has_not_message mess, options = nil
    has_message(mess, options, false)
  end

  def has_error mess, options = nil, inverse = false
    debug "-> ModuleRouteMethods # has_error"
    instance_test_html.has_error( mess, options, inverse )
  end
  def has_error? mess, options=nil, inverse=false
    has_error(mess, (options||{}).merge(evaluate: false), inverse)
  end
  def has_not_error mess, options = nil
    has_error mess, options = nil, true
  end

  # / FIN DES MÉTHODES DE MESSAGES FLASH
  # ---------------------------------------------------------------------

  def url
    @url ||= "#{SiteHtml::TestSuite::current::base_url}/#{raw_route}"
  end

  def request req
    SiteHtml::TestSuite::Request::new(req).execute
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
