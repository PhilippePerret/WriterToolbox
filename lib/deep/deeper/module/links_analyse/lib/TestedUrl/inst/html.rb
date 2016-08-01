# encoding: UTF-8
=begin

  Toutes les méthodes qui concernent le code HTML de la page
  testée.

=end
class TestedPage

  # Code de la page, retourné par la commande Curl
  def raw_code
    @raw_code ||= begin
      rc = retour_curl_commande
      if rc == nil || rc == ''
        raise "Curl ne renvoie rien avec l'url #{url}"
      end
      rc.force_encoding('utf-8')
    rescue Exception => e
      debug e
      error "Erreur avec la page #{url}"
      return ''
    end
  end

  # L'instance NokogiriTextHelper qui permet de faire des
  # recherche et des vérifications sur le code de la page
  # (p.e. méthode have_tag)
  #
  def nokotexthelper
    @nokotexthelper ||= NokogiriTextHelper.new(raw_code)
  end

  # L'instance Nokogiri qui permet de récupérer des éléments
  # de la page
  def nokogiri
    @nokogiri ||= begin
      Nokogiri::HTML(raw_code)
    end
  end

  # Permet d'envoyer en debug le code brut du document
  def debug_code
    debug raw_code.gsub(/</,'&lt;').gsub(/>/,'&gt;')
  end

  # Retourne la liste de tous les liens de l'url
  # C'est un Array d'instances TestedPage::Link
  def links
    @links ||= begin
      l = Array.new
      nokogiri.css('a[href]').each_with_index do |link, ilink|
        link = Link.new(link, ilink)
        l << link
      end
      l
    end
  end

end
