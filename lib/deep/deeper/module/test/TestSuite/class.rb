# encoding: UTF-8
class SiteHtml
class TestSuite
class << self

  attr_accessor :options

  # Initialisation des options de la classe
  #
  # La méthode est appelée par l'instanciation d'une suite
  # de tests.
  def init_options
    @options.merge!( debug: false )
  end

  def debug?  ; options[:debug] == true end

  # Démarrer le débuggage
  def start_debug
    @options[:debug] = true
    debug "\n\n\n---------------- DEBUG ON -----------------\n"
  end
  # Arrêter le débuggage
  def stop_debug
    @options[:debug] = false
    debug "\n\n\n---------------- /DEBUG OFF -----------------\n"
  end

end #/<< self
end #/TestSuite
end #/SiteHtml
