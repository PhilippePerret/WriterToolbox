# encoding: UTF-8
require 'bitly'

class RSBitly
  class << self
    def current
      @current ||= new()
    end
  end # << self

  def configure_bitly
    Bitly.use_api_version_3
    Bitly.configure do |config|
      config.api_version  = 3
      config.access_token = configuration_data[:generic_access_token]
    end
  end
  def configuration_data
    @configuration_data ||= begin
      require './data/secret/data_bitly'
      DATA_BITLY
    end
  end

  def info_bitly
    @info_bitly ||= begin
      configure_bitly
      debug "Bitly.client.shorten(#{long_url})"
      long_url.start_with?('http') || raise( "L'URI http doit impérativement commencer par `http`…" )
      res = Bitly.client.shorten(long_url)
      res
    end
  end

  # Retourne true si le lien existe
  # Noter qu'il existera toujours puisque la méthode fait
  # appel à `info_bibly` qui utilise `shorten`. La seule différence
  # c'est que le résultat met `new_hash?` à true
  def exist?
    @is_existe = info_bitly.new_hash? == false if @is_existe === nil
    @is_existe
  end
  alias :exists? :exist?

  def short_url
    @short_url ||= info_bitly.short_url
  end
  def created_at
    @created_at ||= info_bitly.created_at
  end

  # Résultat qui sera sorti
  def output
    @output ||= ""
  end

  def display_infos
    output << '<pre style="font-size:13pt">'
    output <<
      if exist?
        "=== INFOS sur le lien bitly ===\n"
      else
        "=== CRÉATION du lien bitly ===\n"
      end
    depuis_le = " (depuis le #{created_at.to_i.as_human_date})"
    link_to_short_url = short_url.in_input_text(onfocus:"this.select()", style:'width:240px')
    output << "Existe ?    #{exists?.inspect}#{exists? ? depuis_le : ''}\n"
    output << "long_url  : #{long_url}\n"
    output << "route     : #{route}\n"
    output << "short_url : #{link_to_short_url}\n"
    output << ( "="*40 + "\n" )
    exist? || flash( "Lien Bitly créé avec succès." )
  ensure
    output << "</pre>"
  end

  def destroy
    flash "Pour le moment, on ne peut pas détruire un lien bitly."
  end

  # URL longue, originale, de la page à atteindre
  def long_url
    @long_url ||= begin
      case data[:route]
      when NilClass then nil
      when /^http/  then data[:route]
      when /^www/
        "http://#{data[:route]}"
      else "#{site.distant_url}/#{data[:route]}"
      end
    end
  end

  def route
    @route ||= begin
      if long_url == site.distant_url
        '---'
      else
        long_url.sub(%r{^#{site.distant_url}\/}, '')
      end
    end
  end

  def data
    @data ||= param(:bitly) || {}
  end
end

def bitly ; @bitly ||= RSBitly.current end

# On affiche ou on crée le lien court que si
# une URL ou une route est fournie
bitly.long_url && bitly.display_infos
