# encoding: UTF-8
=begin
Essai pour des tests particuliers
=end
def log mess
  SiteHtml::TestSuite::log mess
end

class SiteHtml
class TestSuite

  class << self

    # Instance de la suite de test courante
    attr_accessor :current

  end #/<< self

  attr_reader :failures
  attr_reader :success
  attr_reader :options


  def initialize  opts = nil
    @options = opts
    parse_options
    self.class::current= self
  end

  # = main =
  #
  # Méthode principale qui joue toutes la suite de tests
  # désirée.
  #
  # +options+
  #   :dossier_test     Le dossier dans lequel jouer les tests
  #   :online           Si true, en online
  def run
    @failures           = Array::new
    @success            = Array::new
    infos[:start_time]  = Time.now
    Dir["#{folder_test_path}/**/*_spec.rb"].each do |p|
      infos[:nombre_files] += 1
      # On passe le test en test courant
      @current = ::SiteHtml::TestSuite::TestFile::new(self, p)
      @current.execute
    end
    infos[:end_time]      = Time.now
    display_resultat
    # debug "failures : #{failures.inspect}"
    # debug "success: #{success.inspect}"
    return "" # pour la console
  end

  def base_url
    if options[:online]
      site.distant_url
    else
      site.local_url
    end
  end

  def log mess; console.sub_log mess end


  def folder_test_path
    @folder_test_path ||= begin
      File.join(['.', 'test', options[:dossier_test]].compact)
    end
  end


  def parse_options
    @options ||= Hash::new
    debug "SiteHtml::Test::options : #{@options.pretty_inspect}"
  end

  # Méthodes appelées par les files (SiteHtml::TestSuite::File) pour
  # enregistrer leurs messages de succès ou d'erreur
  def add_failure ifile, messages
    # debug "-> TestSuite#add_failure"
    infos[:nombre_tests] += 1
    @failures << [infos[:nombre_tests], ifile, messages]
  end
  def add_success ifile, messages
    # debug "-> TestSuite#add_success"
    infos[:nombre_tests] += 1
    @success << [infos[:nombre_tests], ifile, messages]
  end

end #/TestSuite
end #/SiteHtml
