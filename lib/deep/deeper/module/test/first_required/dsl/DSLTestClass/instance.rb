# encoding: UTF-8
=begin

Ouvrir le fichier Test/Implémentation/DSLTestMethod.md pour obtenir
tous les détails

=end
class DSLTestMethod

  # {SiteHtml::TestSuite::TestFile} Instance du fichier
  # possédant la méthode de test.
  attr_reader :tfile

  # Instanciation commune à toutes les méthode de test
  def initialize tfile, &block
    @tfile = tfile
    init
    begin
      # C'est ici qu'on évalue tout le contenu du bloc de test
      instance_eval(&block) if block_given?
    rescue TestUnsuccessfull
      # On passe par ici lorsqu'un test-case échoue
      # Il n'y a rien de particulier à faire puisque TestCase a
      # géré l'enregistrement du message d'erreur (on aurait pu
      # l'envoyer ici, mais la méthode `evaluate` de TestCase est
      # plus facile à lire comme ça)
      #
      # On ajoute cet échec au fichier
      tfile.failure_tests << self
    rescue Exception => e
      # On passe ici si c'est une erreur fonctionnelle
      raise e
    else
      # On peut ajouter ce succès au fichier
      tfile.success_tests << self
    end
  end

  # Initialisation de la méthode de test
  def init
    # Les données du test, qui serviront notamment pour
    # l'affichage.
    @tdata = Hash::new
    @tdata = {
      test_file:            tfile, # instance TestFile du fichier
      start_time:           Time.now,
      end_time:             nil,
      description:          "",
      description_defaut:   nil
    }
    if self.respond_to?(:description_defaut)
      @tdata.merge!(description_defaut: description_defaut)
    end

  end

  # Pour mettre le mode en verbose (même si le fichier ou les tests
  # généraux ont leur options différentes)
  def verbose value = true  ; @verbose = value end
  # Pour mettre quiet à true ou false
  def quiet value = true; @quiet = value end

end
