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
  def test test_name, test_line = nil
    @current_test = test_name
    begin
      resultat = yield
      add_success test_name, test_line, resultat
    rescue Exception => e
      # debug e
      add_failure test_name, test_line, e.message
    end
    add_test test_name, test_line, resultat
  end

  def test_route la_route, test_line = nil
    r = Route::new(la_route)
    test_name = "Test URL #{r.url}"
    begin
      resultat = yield r
      add_success test_name, test_line, resultat
    rescue Exception => e
      # debug e
      # failure e.message
      add_failure test_name, test_line, e.message
    end
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

  def add_failure test_name, line_test, message
    add_test test_name, line_test, false, message
  end
  def add_success test_name, line_test, message
    add_test test_name, line_test, true, message
  end
  def add_test test_name, line_test, resultat, message
    if resultat == true
      self.class::add_success(self, test_name, line_test, message)
    else
      self.class::add_failure(self, test_name, line_test, message)
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
