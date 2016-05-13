# encoding: UTF-8
=begin

Module pour l'exécution des requêtes CURL

=end
class SiteHtml
class TestSuite
class Request
class CURL

  # Le propriétaire de la requête, par exemple une instance
  # {SiteHtml::TestSuite::Form} de formulaire
  #
  # Noter que ce propriétaire doit impérativement charger
  # les méthodes du module ModuleRouteMethods (qui notamment
  # définit la méthode `url` qui retourne l'url à utiliser
  # suivant la route définie)
  attr_reader :owner

  # {Hash} des données envoyées initialement à l'instance
  #   :form       Si true, c'est une simulation de soumission
  #               de formulaire qui est opérée. Les données
  #               doivent alors définir aussi :data
  #   :data       Données transmises en cas de simulation de
  #               formulaire. Elle peut être :
  #               {String} La données telle quelle à transmettre
  #               {Array} Liste de "var=val" qui seront rassemblées
  #               {Hash} Table de key=>valeur qui seront aussi
  #               rassemblées suivant leur classe/type.
  attr_reader :request_data

  # +request_data+ Cf. ci-dessus
  def initialize owner, request_data = nil
    @owner        = owner
    @request_data = request_data
  end

  # Exécution de la requête, qui retourne le code obtenu
  def execute
    debug "-> CURL#execute"
    request.execute
    # Après l'exécution du code, on doit modifier l'instance
    # Nokogiri::HTML du propriétaire en utilisant sa méthode
    # `nokogiri_html` qui contient l'instance.
    # Le propriétaire doit posséder cette méthode
    unless owner.respond_to?(:nokogiri_html)
      raise "Le propriétaire de classe #{owner.class} devrait répondre à la méthode `nokogiri_html=` pour actualiser l'instance qui contient le code du document."
    end
    owner.nokogiri_html= content
    return true
  end

  # = main =
  #
  # Le code de la page retournée lors de la soumission de la
  # requête CURL de l'instance
  #
  def content
    @content ||= begin
      begin
        request.content
      rescue Exception => e
        debug e
        "[### PROBLÈME EN SOUMETTANT LA REQUETE `#{built_request}` : #{e.message}]"
      end
    end
  end

  # Le contenu en version Nokogiri::HTML
  def nokogiri_html
    @code_nokogiri ||= Nokogiri::HTML(content)
  end

  # Instance Request de la requête curl
  def request
    @request ||= SiteHtml::TestSuite::Request::new( built_request )
  end

  # Requête construite
  def built_request
    @built_requete ||= "curl#{req_options}#{req_data} #{req_url}"
  end

  # True si la requête est une simulation de soumission
  # de formulaire
  def form_simulation?
    @is_form_simulation ||= !!request_data[:form]
  end

  def req_options
    @req_options ||= begin
      arr_opts = Array::new
      # arr_opts << "F" if request_data[:form]
      if arr_opts.empty?
        ""
      else
        " " + "-#{arr_opts.join('')}"
      end
    end
  end
  def req_data
    @req_data ||= begin
      if request_data[:data].nil?
        ""
      else
        datareq = if form_simulation? && request_data[:data].has_key?(:fields)
          # Si les données n'ont pas été préparées
          h = Hash::new
          # On prend tous les champs qui définissent une
          # propriété name
          request_data[:data][:fields].each do |k, v|
            next unless v.has_key?(:name)
            h.merge! k => v[:value]
          end
        else
          request_data[:data]
        end

        datareq = case datareq
        when String then request_data[:data]
        when Hash
          request_data[:data].collect do |k, v|
            # v = CGI::escape v
            v = v.to_s.match(/ /) ? "\\\"#{v}\\\"" : v
            "#{k}=#{v}"
          end.join('&')
        when Array  then request_data[:data].join(';')
        else
          raise "Propriété :data incorrecte pour une requête CURL"
        end
        # " " + "--data-urlencode \"#{datareq}\""
        " " + "--data \"#{datareq}\""
        # " " + datareq
      end
    end
  end
  def req_url
    @req_url ||= owner.url
  end

end #/CURL
end #/Request
end #/TestSuite
end #/SiteHtml
