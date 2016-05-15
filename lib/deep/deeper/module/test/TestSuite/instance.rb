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

  # attr_reader :failures # OBSOLÈTE
  # attr_reader :success  # OBSOLÈTE

  # Liste des instances TestFile des fichiers tests traités
  attr_reader :test_files


  attr_reader :options


  def initialize  opts = nil
    @options = opts
    parse_options
    self.class::current= self
    # Il faut aussi initialiser les options de la class, qui permettent
    # pour le moment de gérer la mise en route et l'arrêt du débuggage
    self.class::init_options
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
    @test_files         = Array::new
    infos[:start_time]  = Time.now

    test_files = Dir["#{folder_test_path}/**/*_spec.rb"]
    debug "Fichiers tests : #{test_files.join(', ')}"
    Dir["#{folder_test_path}/**/*_spec.rb"].each do |p|
      infos[:nombre_files] += 1
      # On passe le test en test courant
      @current = ::SiteHtml::TestSuite::TestFile::new(self, p)
      @current.execute
      @test_files << @current
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
    @options.merge!(debug: false) unless @options.has_key?(:debug)
    debug "SiteHtml::Test::options : #{@options.pretty_inspect}"
  end

end #/TestSuite
end #/SiteHtml
