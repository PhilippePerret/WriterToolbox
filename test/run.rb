# encoding: UTF-8
=begin

  Module appelé quand on joue la commande `test run`

  Il permet de définir très précisément les tests qui vont être
  joués.

=end
# Il faut être grand manitou pour lancer ce test
raise_unless user.manitou?

SiteHtml::TestSuite.configure do


  # LISTE DES FICHIERS-TEST
  # -----------------------
  # On peut les spécifier de plusieurs façon :
  #   - en version relative entière : "./test/mini/un_test_spec.rb"
  #   - en version relative depuis ./test : "mini/un_test_spec.rb"
  #   - en version relative simplifiée : "mini/un_test"
  current.files = ["mini/database"]

  # LIEU DU TEST
  # ------------
  current.options[:online] = false

end
