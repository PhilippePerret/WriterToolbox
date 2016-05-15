# encoding: UTF-8
# ---------------------------------------------------------------------
#   Instance SiteHtml::TestSuite::File
#
#   Une instance d'un fichier de test
#
# ---------------------------------------------------------------------
class SiteHtml
class TestSuite
class TestFile

  # {SiteHtml::TestSuite} Instance de la suite de ce fichier
  attr_reader :test_suite

  # {String} Path du test
  attr_reader :path

  # {String} Nom du test
  # C'est le nom général, défini par exemple par `test_route`
  attr_reader :test_name


  # {Array} Liste des messages de succès. En fait, c'est une
  # liste d'instances ATest
  # La seconde liste contient les messages d'échec
  attr_reader :success_tests
  attr_reader :failure_tests


  # +tsuite+  SiteHtml::TestSuite courante (possédant ce fichier)
  def initialize tsuite, path
    @test_suite = tsuite
    @path       = path
    @success_tests = Array::new
    @failure_tests = Array::new
  end

  # = main =
  #
  # Méthode principale lançant l'exécution du code
  # de tout le fichier
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

  def log mess
    self.class::log mess
  end

  # Pour mettre en route le débug lorsque ces méthodes sont à la
  # "racine" du fichier (i.e. pas dans une test-méthode)
  def debug_start;  SiteHtml::TestSuite::debug_start  end
  def debug_stop;   SiteHtml::TestSuite::debug_stop   end

end #/TestFile
end #/TestSuite
end #/SiteHtml
