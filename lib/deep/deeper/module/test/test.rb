# encoding: UTF-8
class SiteHtml
class Test

  # ---------------------------------------------------------------------
  #   Instance SiteHtml::Test
  # ---------------------------------------------------------------------

  # {String} Path du test
  attr_reader :path
  def initialize path
    @path = path
  end

  # ---------------------------------------------------------------------
  #   Méthodes pour les tests

  # Définit un nouveau test à accomplir
  def test test_name, &bloc
    @current_test = test_name
    begin
      resultat = yield
    rescue Exception => e
      debug e
      error e.message
    end
    add_test test_name, resultat
  end

  def test_route la_route
    test_name = "Test route #{la_route}"
    begin
      resultat = yield Route::new(la_route)
    rescue Exception => e
      debug e
      error e.message
    end
    add_test test_name, resultat
  end

  # Retourne l'instance
  def exec_curl request
    return Request::new(self, request).execute
  end

  def route route_str
    Route::new(route_str)
  end

  # / Fin méthodes des tests
  # ---------------------------------------------------------------------

  def execute
    self.class::class_eval do
      define_method(:run) do
        eval(File.open(path,'rb'){|f| f.read})
      end
    end
    run
  rescue Exception => e
    debug e
    error e.message
  end

  def add_test test_name, resultat
    if resultat == nil || resultat == true
      self.class::add_success(self, test_name, "OK")
    else
      self.class::add_failure(self, test_name, resultat)
    end
  end

  def failure mess
    self.class::add_failure(self, mess)
  end
  def success mess
    self.class::add_success(self, mess)
  end

  def log mess
    self.class::log mess
  end

end #/Test
end #/SiteHtml
