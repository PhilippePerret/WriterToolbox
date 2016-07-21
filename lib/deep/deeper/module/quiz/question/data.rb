# encoding: UTF-8
=begin

  Module pour les données (absolutes) de la question.

=end
class ::Quiz
  class Question

    include MethodesMySQL

    # ---------------------------------------------------------------------
    #   DATA ENREGISTRÉES
    # ---------------------------------------------------------------------
    def options
      @options ||= get(:options) || options_default
    end
    # ---------------------------------------------------------------------
    #   DATA VOLATILES
    # ---------------------------------------------------------------------

    # Pour les options, voir le fichier options.rb
    
  end #/Question
end #/Quiz
