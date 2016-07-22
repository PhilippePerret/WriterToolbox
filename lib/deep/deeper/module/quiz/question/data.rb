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

    # Pour les options, voir le fichier options.rb

    # ---------------------------------------------------------------------
    #   DATA VOLATILES
    # ---------------------------------------------------------------------

    def hreponses
      @hreponses ||= begin
        if reponses.nil?
          {}
        else
          JSON.parse(reponses).to_sym
        end
      end
    end

  end #/Question
end #/Quiz
