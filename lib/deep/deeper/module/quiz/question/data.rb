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
    def question    ; @question   ||= get(:question)    end
    def reponses    ; @reponses   ||= get(:reponses)    end
    def raison      ; @raison     ||= get(:raison)      end
    def indication  ; @indication ||= get(:indication)  end
    def type        ; @type       ||= get(:type) || type_default end
    # ---------------------------------------------------------------------
    #   DATA VOLATILES
    # ---------------------------------------------------------------------

    # Pour les options, voir le fichier options.rb

  end #/Question
end #/Quiz
