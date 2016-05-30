# encoding: UTF-8
=begin

  Module appelé quand on joue la commande `test run` ou `run test`

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
  #   - par un dossier : Dir['./test/unit/extension/*_spec.rb']
  # current.files = ['deep/user/destroy']
  current.files = ['deep/unan/base']

  # LIEU DU TEST
  # ------------
  # current.options[:online] = true
  current.options[:offline] = true

  # VERBOSITÉ
  # ----------
  options[:verbose] = true
  current.options[:verbose] = true

end
