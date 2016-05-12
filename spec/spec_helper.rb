# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.

# require 'rspec-steps'
# require 'rspec-steps/monkeypatching'

# require 'capybara/rspec'
# Pour les tests avec have_tag etc.
require 'rspec-html-matchers'


require 'capybara/rspec'
require 'capybara-webkit'

# Capybara.javascript_driver = :webkit
# Capybara.javascript_driver = :webkit
Capybara.javascript_driver  = :selenium
Capybara.default_driver     = :selenium


# On requiert tout ce que requiert l'index du site
# Mais est-ce vraiment bien, considérant tout ce qui est indiqué ci-dessus ?
require './lib/required'

require_folder './spec/support'


# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|

  # Pour les tests have_tag etc.
  config.include RSpecHtmlMatchers

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end

  config.before :suite do

    # On prend le temps de départ qui permettra de savoir les choses
    # qui ont été créées au cours des tests et pourront être
    # supprimées à la fin de la suite de tests
    @start_suite_time = Time.now.to_i

    # Un Array contenant les instances ou les identifiants des
    # users qu'il faudra détruire à la fin des tests.
    $users_2_destroy = Array::new

    # On fait un gel du site actuel pour pouvoir le remettre
    # ensuite.
    SiteHtml.instance.require_module('gel')
    SiteHtml::Gel::gel('before-test')

  end

  # À faire avant chaque module de test
  config.before :all do

  end

  config.after :suite do
    debug "\n\n"

    # Destruction des users qui ont été créés au cours des
    # tests
    # OBSOLÈTE maintenant qu'on travail avec les gels
    # $users_2_destroy.each do |uref|
    #   u = uref.instance_of?(User) ? uref : User::get(uref)
    #   u.remove # appelle aussi `u.app_remove` propre à l'app.
    # end

    # Destruction de tout ce qui a été créé au cours des tests,
    # c'est-à-dire après le @start_suite_time
    # OBSOLÈTE maintenant qu'on travaille avec les gels
    # if Unan::table_programs.exist?
    #   nb_init = Unan::table_programs.count
    #   Unan::table_programs.delete(where:"created_at >= #{@start_suite_time}")
    #   nb_destroyed = nb_init - Unan::table_programs.count
    #   debug "Nombre de programmes détruits dans la table unan_hot.programs : #{nb_destroyed}"
    # else
    #   debug "Aucun programme détruit (table unan_hot.programs inexistante)"
    # end
    # if Unan::table_projets.exist?
    #   nb_init = Unan::table_projets.count
    #   Unan::table_projets.delete(where:"created_at >= #{@start_suite_time}")
    #   nb_destroyed = nb_init - Unan::table_projets.count
    #   debug "\nNombre de projets détruits dans la table unan_hot.projets : #{nb_destroyed}"
    # else
    #   debug "Aucun projet détruit (table unan_hot.projets inexistante)"
    # end

    SiteHtml.instance.require_module('gel')
    SiteHtml::Gel::degel('before-test')

  end


  # Méthode à appeler dans le before(:all) de certains tests pour
  # tout ré-initialiser
  def reset_all_variables

    if defined?(User)
      User::instance_variables.each do |iv|
        User.remove_instance_variable(iv)
      end
    end
    if defined?(site)
      site.instance_variables.each{|k|site.instance_variable_set(k,nil)}
      @site = nil
    end

    if defined?(Unan)
      Unan.instance_variables.each { |k| Unan.remove_instance_variable k }
      if defined?(Unan::Program)
        Unan::Program.instance_variables.each { |k| Unan::Program.remove_instance_variable k }
      end
      if defined?(Unan::Projet)
        Unan::Projet.instance_variables.each { |k| Unan::Projet.remove_instance_variable k }
      end
    end
    # @site   = nil
    # @forum  = nil
  end

  # NE PAS L'UTILISER DANS reset_all_variables, car ça a justement été
  # mis à part pour ne pas l'utiliser avec
  def reset_forum_variables
    return unless defined?(Forum)
    Object.send(:remove_const, 'Forum')
    site.require_objet('forum', forcer = true)
    forum.instance_variables.each{|k|forum.remove_instance_variable(k)} rescue nil
    # Forum.instance_variables.each{|k|Forum.remove_instance_variable(k)}
  end
  alias :reset_variables_forum :reset_forum_variables

  def reset_variables_unanunscript
    Unan::instance_variables.each{|k|Unan::remove_instance_variable(k)}
    Unan::Program::instance_variables.each{|k|Unan::Program::remove_instance_variable(k)}
  end

  def require_folder folder
    Dir["#{folder}/**/*.rb"].each{ |m| require m }
  end

  # Pour catcher les messages débug
  def debug str
    puts "DBG: #{str.strip}\n"
  end
  # Pour catcher les messages log (par exemple pour le cron)
  def log str
    puts "LOG: #{str.to_s.strip}"
  end

  def degel gel_name
    site.require_module('gel')
    SiteHtml::Gel::degel gel_name
  end
  def gel gel_name
    site.require_module('gel')
    SiteHtml::Gel::gel gel_name
  end



  # ---------------------------------------------------------------------
  #   Concernant la navigation (features)
  # ---------------------------------------------------------------------

  # Pour pouvoir utiliser `visit home`
  def home
    @home ||= "http://localhost/WriterToolbox"
  end



  # ---------------------------------------------------------------------
  #   Screenshots
  # ---------------------------------------------------------------------
  def shot name
    name = "#{Time.now.to_i}-#{name}"
    page.save_screenshot("./spec/screenshots/#{name}.png")
  end
  def empty_screenshot_folder
    p = './spec/screenshots'
    FileUtils::rm_rf p if File.exists? p
    Dir.mkdir( p, 0777 )
  end

end
