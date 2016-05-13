# encoding: UTF-8
# ---------------------------------------------------------------------
#
#   Class SiteHtml::TestSuite::File::ATest
#   --------------------------------------
#
#   Pour la gestion d'un "example" comme l'appelle RSpec
# ---------------------------------------------------------------------
class SiteHtml
class TestSuite
class TestFile
class ATest

  # Instance SiteHtml::TestSuite::File du fichier qui contient
  # ce test
  attr_reader :file

  # {Array} Liste des messages des succès
  # Note : On ne consigne que les succès puisqu'une failure interrompra
  # ce a-test.
  attr_reader :messages

  # {String} Le nom du test par défaut, c'est-à-dire ce qu'il fait
  # Pourra être remplacé par les définitions de `options`
  attr_reader :default_name

  # {String} Libellé qui peut être défini par les options.
  # Noter que ce n'est pas celui-ci qui sera utilisé, c'est la
  # méthode-property `libelle` qui est appelée.
  attr_reader :test_libelle

  # {Hash} Les options, comme par exemple le numéro de ligne
  attr_reader :options

  def initialize instance_file, def_name, options = nil
    @file         = instance_file
    @default_name = def_name
    @options      = options
    @messages     = Array::new
    analyse_options
    # On le met automatique en atest courant pour la
    # gestion des cas
    ::SiteHtml::TestSuite::Case::current_atest = self
  end

  def evaluate
    begin
      yield
    rescue Exception => e
      # => Failure
      debug e
      # On ajoute la failure.
      # Noter que les réussites, elles, sont enregistrées au
      # fur et à mesure par les messages renvoyés.
      # La méthode `add_failure` définit aussi @has_failed qui
      # permettra au fichier de savoir que c'est un échec.
      add_failure e.message
    end
    # On ajoute le résultat de ce test au fichier
    file.add_test( self )
  end

  # Retourne le libellé à donner à ce test
  #
  # Noter qu'on ajoute le nom par défaut (nom générique du
  # test) sauf si +no_default_name+ est true
  def libelle no_default_name = false
    if test_libelle.nil?
      default_name
    else
      libe = test_libelle
      libe += "(TEST #{default_name})".in_div(class:'defname') unless no_default_name
      libe
    end
  end

  # Méthode pour ajouter un message au test courant.
  # Noter que c'est toujours un message de succès qui peut être enregistré
  # ici puisqu'une failure interrompt le cas
  def add_success message
    @messages << [self.file, self, message]
  end

  def add_failure message
    @messages << [self.file, self, message]
    @has_failed = true
  end

  def tline     ; @tline ||= options[:line]   end

  def success?  ; !failed?            end
  def failed?   ; @has_failed == true end


  # Pour parser le dernier argument envoyé à la méthode
  # de test
  def analyse_options
    opts = @options
    case opts
    when NilClass
      # Rien à faire
      return
    when Fixnum
      @test_line = opts
    when String
      # Si le dernier argument est un string, c'est le libellé
      # à donner au test.
      @test_libelle = opts
    when Hash
      @test_libelle = opts[:libelle]  if opts.has_key?(:libelle)
      @test_line    = opts[:line]     if opts.has_key?(:line)
    end
  end

end #/ATest
end #/TestFile
end #/TestSuite
end #/SiteHTML
