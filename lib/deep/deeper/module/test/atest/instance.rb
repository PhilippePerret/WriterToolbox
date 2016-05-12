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

  # {String} Le nom du test, c'est-à-dire ce qu'il fait
  attr_reader :name

  # {Hash} Les options, comme par exemple le numéro de ligne
  attr_reader :options

  def initialize instance_file, tname, options = nil
    @file     = instance_file
    @name     = tname
    @options  = options
    @messages = Array::new

    # On le met automatique en atest courant pour la
    # gestion des cas
    ::SiteHtml::TestSuite::Case::current_atest = self
  end

  def evaluate #proc
    begin
      # # yield r
      # proc.call
      yield
    rescue Exception => e
      # => Failure de ce "ATest"
      debug e
      add_failure e.message
    end
    file.add_test( self )
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


end #/ATest
end #/TestFile
end #/TestSuite
end #/SiteHTML
