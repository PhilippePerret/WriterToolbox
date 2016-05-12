# encoding: UTF-8
# ---------------------------------------------------------------------
#   Instance SiteHtml::TestSuite::File
#
#   Toutes les initialisations possibles de tests
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
