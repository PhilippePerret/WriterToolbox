# encoding: UTF-8
class TestedPage
  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # IDentifiant de l'instance dans la classe
  #
  # Pour la récupérer :
  #     instance = TestedPage[<id>]
  #
  attr_accessor :id

  attr_reader :route

  # Liste Array des erreurs éventuellement rencontrées
  attr_reader :errors

  # Instanciation d'une url
  def initialize route
    @route = route.strip
    self.class << self
    @errors = Array.new
  end

  def url
    @url ||= File.join(self.class.base_url, route)
  end

  # Code de la page, retourné par la commande Curl
  def raw_code
    @raw_code ||= begin
      `curl -s #{url}`.force_encoding('utf-8')
    rescue Exception => e
      debug e
      error "Erreur avec la page #{url}"
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
