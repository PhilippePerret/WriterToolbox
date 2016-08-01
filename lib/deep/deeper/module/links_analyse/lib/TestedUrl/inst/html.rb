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

  # Le code brut, avec toutes les balises transformées en
  # entités HTML pour affichage dans la page HTML
  #
  # En plus, on épure le code et on le rend plus lisible
  #
  def raw_code_report
    rc = raw_code.force_encoding('utf-8').gsub(/</,'&lt;').gsub(/>/,'&gt;')
    rc = rc.gsub(/\n([ \t ]*)\n/, "\n")
    rc = rc.gsub(/\n+/, "\n")
    rc = rc.gsub(/&lt;section/, "\n\n&lt;section")
    rc = rc.gsub(/&lt;\/section&gt;/, "&lt;/section&gt;\n\n")
    return rc
  rescue Exception => e
    debug e
    return "[PROBLÈME AVEC LE CODE DE CETTE PAGE : #{e.message}]"
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
