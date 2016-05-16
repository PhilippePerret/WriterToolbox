# encoding: UTF-8
=begin

  Les méthodes ou objets utilisables par les fichiers de test

=end
class DSLTestMethod

  if defined?(ModuleCaseTestMethods)
    # Sinon, il sera inclus après le chargement du module
    include ModuleCaseTestMethods
  end

  # Pour décrire plus précisément le test
  def description str = nil
    if str.nil?
      @tdata[:description]
    else
      @tdata[:description] = str
    end
  end

  # Instance SiteHtml::TestSuite::HTML qui permet de
  # tester le code retourné dernièrement
  #
  # Noter que ça n'est possible qu'avec une test-méthode de
  # type "route", c'est-à-dire qui donne une route dans ses
  # données.
  #
  # Noter que l'instance est consignée dans une variable
  # d'instance, donc elle doit être ré-initialisée par
  # toute méthode qui rechargerait un code différent.
  #
  # On peut appliquer à cette instance toutes les méthodes de
  # type `has_message`, `has_tag`, etc.
  #
  def html
    raise (error_no_test_route "html") unless route_test?
    @html ||= SiteHtml::TestSuite::HTML::new(self, nokogiri_html)
  end

end
