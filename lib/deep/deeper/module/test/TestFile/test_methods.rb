# encoding: UTF-8
# ---------------------------------------------------------------------
#   Instance SiteHtml::TestSuite::File
#
#   Méthodes de test pour les feuilles de test
#
# ---------------------------------------------------------------------
class SiteHtml
class TestSuite
class TestFile

  # Pour tester une page
  def test_route la_route, options = nil
    r = Route::new(la_route)
    atest = ATest::new(self, "URL #{r.url}", options)
    atest.evaluate{ yield r }
  end

  # Pour tester un formulaire
  def test_form la_route, les_data, options = nil
    f     = SiteHtml::TestSuite::Form::new(la_route, les_data)
    atest = ATest::new(self, "FORM #{f.url}", options)
    atest.evaluate{ yield f }
  end


  # / Fin méthodes des tests
  # ---------------------------------------------------------------------

end #/TestFile
end #/TestSuite
end #/SiteHtml