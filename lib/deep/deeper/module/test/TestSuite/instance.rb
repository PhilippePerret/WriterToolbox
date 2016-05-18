# encoding: UTF-8
=begin
Essai pour des tests particuliers
=end
def log mess
  SiteHtml::TestSuite::log mess
end

class SiteHtml
class TestSuite


  # {User} Administrateur courant, celui qui fait passer les
  # tests.
  # On doit le prendre pour le reconnecter à la fin des
  # tests
  attr_reader :current_admin

  # {Array} Liste des instances {SiteHtml::TestSuite::TestFile}
  # des fichiers-tests de cette suite.
  attr_reader :test_files

  # +opts+ Options transmises à la ligne de commande, sauf
  # si c'est `test run` ou `run test` qui est appelé, dans lequel
  # cas on appelle SiteHtml::TestSuite.configure depuis le fichier
  # ./test/run.rb pour lancer des tests particuliers.
  def initialize  opts = nil
    self.class::current= self
    unless opts.nil?
      @options = opts
      parse_options
    else
      @options = Hash::new
    end
    # Il faut aussi initialiser les options de la class, qui permettent
    # pour le moment de gérer la mise en route et l'arrêt du débuggage
    # Warning : La méthode `parse_options` ci-dessous enregistre déjà
    # des valeurs dans les options, il ne faut donc pas réinitialiser
    # complètement le Hash des options.
    self.class::init_options
  end

  # = MAIN =
  #
  # MÉTHODE PRINCIPALE QUI JOUE LA SUITE DE TESTS
  #
  def run
    @current_admin = User::new(user.id)
    infos[:start_time]  = Time.now
    @failures           = Array::new
    @success            = Array::new
    @test_files         = Array::new
    freeze_current_db_state
    regularise_options
    if debug?
      debug "Fichiers tests : #{files.join(', ')}"
    end
    files.each do |p|
      infos[:nombre_files] += 1
      # On passe le test en test courant
      @current = ::SiteHtml::TestSuite::TestFile::new(self, p)
      @current.execute
      @test_files << @current
    end
    infos[:end_time]      = Time.now

    unfreeze_current_db_state

    # === AFFICHAGE DU RÉSULTAT ===
    display_resultat

    # reconnecte_administrateur

    return "" # pour la console
  rescue Exception => e
    (@freezed && @unfreezed) || unfreeze_current_db_state
    debug e
    raise e
  end

  # Liste des paths de tous les fichiers testés
  # Noter que ça peut être défini par le fichier ./test/run.rb par
  # la méthode configure de la classe.
  def files
    @files ||= Dir["#{folder_test_path}/**/*_spec.rb"]
  end
  def files= liste
    @files = liste.collect do |relpath|
      relpath = "./test/#{relpath}" unless relpath.start_with?("./test")
      relpath += "_spec.rb" unless relpath.end_with?("_spec.rb")
      if File.exist?(relpath)
        relpath
      else
        error "Le fichier-test `#{relpath}` est introuvable."
        nil
      end
    end.compact
    debug "= @files = #{@files.inspect}"
  end

  def base_url
    if options[:online]
      site.distant_url
    else
      site.local_url
    end
  end

  def log mess; console.sub_log mess end

  def infos
    @infos ||= {
      start_time:           nil,
      end_time:             nil,
      duree_db_backup:      nil,
      duree_db_unbackup:    nil,
      nombre_files:         0,  # fichiers tests
      nombre_tests:         0,  # test-méthodes
      nombre_cas:           0   # case-méthodes
    }
  end


  def folder_test_path
    @folder_test_path ||= begin
      File.join(['.', 'test', options[:dossier_test]].compact)
    end
  end
  def folder_test_path= value; @folder_test_path = value end

  # À la fin des tests, on essaie de reconnecter l'administrateur
  def reconnecte_administrateur
    debug "-> reconnecte_administrateur"
    debug "Admin identifié ? #{current_admin.identified?.inspect}"
    debug "session[user_id] = #{app.session['user_id'].inspect}"
    current_admin.proceed_login
    debug "Admin identifié ? #{current_admin.identified?.inspect}"
    debug "session[user_id] = #{app.session['user_id'].inspect}"
    debug "<- reconnecte_administrateur"
  end
end #/TestSuite
end #/SiteHtml
