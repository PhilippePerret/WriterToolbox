# encoding: UTF-8
class SiteHtml
class TestSuite
class << self

  # Instance de la suite de test courante
  attr_accessor :current

  # Options générales
  attr_accessor :options

  # Initialisation des options de la classe
  #
  # La méthode est appelée par l'instanciation d'une suite
  # de tests.
  def init_options
    @options ||= Hash::new
    @options.merge!( debug: false ) unless @options.has_key?(:debug)
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

  # Valeurs prises dans la test-suite courante
  def online?   ; self.current.online?  end
  def offline?  ; self.current.offline? end

end #/<< self
end #/TestSuite
end #/SiteHtml
