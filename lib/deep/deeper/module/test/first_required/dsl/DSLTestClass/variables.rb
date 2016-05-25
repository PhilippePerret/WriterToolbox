# encoding: UTF-8
class DSLTestMethod

  def let var_name, &block
    !self.respond_to?(var_name) || raise("Le nom de variable #{var_name.inspect} est impossible : C'est une méthode existante.")
    SiteHtml::TestSuite.set_variable var_name, &block
  end

  # OBSOLÈTE
  # Maintenant, il y a une seule méthode method_missing dans
  # l'extension `Object` et des méthodes `self_method_missing`
  # propres aux classes.
  # def method_missing method
  #   as_variable = SiteHtml::TestSuite.get_variable method
  #   as_variable != :__unknown_test_variable__ || raise("La méthode #{method.inspect} est inconnue des test-méthodes…")
  #   as_variable
  # end

end
