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


  def test_form route, data_form=nil, options=nil, &bloc
    SiteHtml::TestSuite::TestForm::new self, route, data_form, options, &bloc
  end
  def test_route route, options=nil, &bloc
    SiteHtml::TestSuite::TestRoute::new( self, route, options, &bloc )
  end
  def test_base table_specs, options=nil, &block
    SiteHtml::TestSuite::TestBase::TestTable::new(self, table_specs, options, &block)
  end

  # / Fin méthodes des tests
  # ---------------------------------------------------------------------

end #/TestFile
end #/TestSuite
end #/SiteHtml
