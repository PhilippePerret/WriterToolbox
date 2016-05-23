# encoding: UTF-8
# ---------------------------------------------------------------------
#   Instance SiteHtml::TestSuite::File
#
# ---------------------------------------------------------------------
class SiteHtml
class TestSuite
class TestFile

  # Méthode pour décrire le fichier-test en début de méthode
  def description str = nil
    @description = str unless str.nil?
    @description
  end
  
  # Pour définir ou récupérer des variables de test en dehors du
  # bloc des test-méthodes
  def let var_name, &block
    SiteHtml::TestSuite.set_variable var_name, &block
  end
  def get var_name
    SiteHtml::TestSuite.get_variable var_name
  end

end #/TestFile
end #/TestSuite
end #/SiteHtml
