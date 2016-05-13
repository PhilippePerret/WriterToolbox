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
  def test_route la_route, test_line = nil
    r = Route::new(la_route)
    atest = ATest::new(self, "URL #{r.url}")
    atest.evaluate{ yield r }
  end

  # Pour tester un formulaire
  def test_form la_route, les_data, options = nil
    f     = SiteHtml::TestSuite::Form::new(la_route, les_data)
    atest = SiteHtml::TestSuite::ATest::new(self, "FORM #{f.url}")
    atest.evaluate{ yield f }
  end

  # Définit un nouveau test à accomplir
  def test tname, tline = nil
    atest = ATest::new(self, tname, {line: tline})
    atest.evaluate{ yield }
  end

  # / Fin méthodes des tests
  # ---------------------------------------------------------------------

end #/TestFile
end #/TestSuite
end #/SiteHtml
