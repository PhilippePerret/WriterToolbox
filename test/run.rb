# encoding: UTF-8
=begin

Module appelé quand on joue la commande `test run`

=end
# Il faut être grand manitou pour lancer ce test
raise_unless user.manitou?

SiteHtml::TestSuite.configure do |config|

  # On configure les tests ici
  
end
