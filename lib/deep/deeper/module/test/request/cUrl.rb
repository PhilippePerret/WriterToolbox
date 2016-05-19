# encoding: UTF-8
=begin

Module pour l'exécution des requêtes CURL

=end
require 'time'

class SiteHtml
class TestSuite
class Request
class CURL

  class << self

    # {SuperFile} Fichier contenant les headers retournés
    # par les requêtes
    def tmp_request_header_path
      @tmp_request_header_path ||= begin
        `mkdir -p ./tmp/test`
        SuperFile::new('./tmp/test/curl_req_header')
      end
    end

    def tmp_request_cookie_jar_path
      @tmp_request_cookie_jar_path ||= begin
        `mkdir -p ./tmp/test`
        SuperFile::new('./tmp/test/curl_req_cookie_jar')
      end
    end
  end

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
    # debug "-> CURL#execute"
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

  # = main =
  #
  # {THash} Header décomposé
  #
  # C'est une table avec tous les renseignements possibles
  # tirés du fichier enregistré avec --dump-header
  #
  # Noter que c'est un {THash} qui est retourné, donc un
  # {Hash} qui répond aux méthodes de test.
  #
  def header
    @header ||= begin

      header_lines = raw_header.strip.split("\n")
      http = header_lines.shift

      h = THash::new(owner)

      # Analyse de la première ligne
      http_version, status_code, human_status = http.split(' ')
      h.merge!(
        http_version: http_version,
        status_code:  status_code.to_i,
        human_status:  human_status
      )
      # Analyse des lignes autres que la première
      header_lines.each do |line|
        property, value = line.scan(/^([\-a-zA-Z]+):(.*)$/).first
        case property
        when 'Date'
          value = Time.parse(value)
        when 'Set-Cookie'
          h[:cookies] ||= []
          cookie = {}
          value.split(';').each do |dpar|
            puts "dpar : #{dpar.inspect}"
            hval = CGI::parse(dpar.strip)
            k = hval.keys.first
            v = hval.values.first.first
            v = Time.parse(v) if k == "expires"
            hval[k] = v
            cookie.merge! hval
          end
          h[:cookies] << cookie
          next
        when "Content-Length"
          value = value.to_i
        end
        h.merge!( property.downcase.gsub(/\-/,'_').to_sym => value )
      end
      # Pour mettre le h dans header
      h
    end
  end

  # Session ID
  #
  # Il se trouve dans l'entête (header) de la requête CURL
  # transmise, avec le nom du cookie propre au site, qu'on
  # peut définir dans la configuration par site.cookie_session_name
  def session_id
    @session_id ||= begin
      sid = nil
      header[:cookies].each do |dcook|
        if dcook.key?(site.cookie_session_name || "SESSRESTSITEWTB" )
          sid = dcook[site.cookie_session_name || "SESSRESTSITEWTB"]
          break
        end
      end
      sid != nil || error("Il faut définir site.cookie_session_name dans le fichier de configuration (./objet/site/config.rb) pour pouvoir récupérer l'ID de sessions.")
      sid
    end
  end

  # Contenu du header retourné par la requête Curl
  #
  # Quelque soit la requête, puisqu'il est enregistré par le
  # biais de `--dump-header`
  #
  def raw_header
    @raw_header ||= tmp_request_header_path.read
  end

  # Le contenu en version Nokogiri::HTML
  def nokogiri_html
    @code_nokogiri ||= Nokogiri::HTML(content)
  end

  # Instance Request de la requête curl
  def request
    @request ||= SiteHtml::TestSuite::Request::new( built_request )
  end

  FAKE_SESSION_ID = "400d4d25b9c540ce9d1d745231764ae4"
  # Requête construite
  def built_request
    @built_request ||= begin
      "curl #{req_options}#{req_data}"+
      " --dump-header #{tmp_request_header_path}"+
      " --cookie #{tmp_request_cookie_jar_path}"+
      " #{req_url}"
    end
  end

  def tmp_request_header_path
    @tmp_request_header_path ||= self.class.tmp_request_header_path
  end
  def tmp_request_cookie_jar_path
    @tmp_request_cookie_jar_path ||= self.class.tmp_request_cookie_jar_path
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
