# encoding: UTF-8
=begin

  Module pour les données (absolutes) de la question.

=end
class Quiz
  class Question

    include MethodesMySQL

    # ---------------------------------------------------------------------
    #   DATA ENREGISTRÉES
    # ---------------------------------------------------------------------
    def question    ; @question   ||= get(:question)    end
    def reponses    ; @reponses   ||= get(:reponses)    end
    def groupe      ; @groupe     ||= get(:groupe)      end
    def raison      ; @raison     ||= get(:raison)      end
    def indication  ; @indication ||= get(:indication)  end
    def type        ; @type       ||= get(:type) || type_default end

    # Pour les options, voir le fichier options.rb

    # ---------------------------------------------------------------------
    #   DATA VOLATILES
    # ---------------------------------------------------------------------

    # Les réponses, sous forme de hash
    #
    # Attention, ce Hash n'est pas à confondre avec le hash
    # `ureponse` qui contient les réponses de l'user à cette question,
    # s'il y a répondu
    #
    def hreponses
      @hreponses ||= begin
        if reponses.nil?
          {}
        else
          JSON.parse(reponses).to_sym
        end
      end
    end

    # Les réponses de l'user à cette question, s'il y a répondu
    # C'est NIL si aucune réponse n'est donnée (affichage du quiz)
    # ou c'est un Hash contenant notamment :
    #   :is_good      True si la réponse est juste
    #   :rep_index    L'index de la réponse ou les index si checkboxes
    #                 PAR COMMODITÉ, ON TRANSFORME TOUJOURS CETTE VALEUR
    #                 EN LISTE.
    #   :best_reps    Les meilleures réponses (si plusieurs)
    #   :good_rep     La meilleur réponse (si une seule)
    #
    def ureponse
      @ureponse ||= begin
        ureps = quiz.ureponses || {}
        urep = ureps[id.to_i]
        urep.nil? || begin
          rindex = urep[:rep_index]
          urep[:rep_index] = [rindex] unless rindex.instance_of?(Array)
        end
        # debug "ureponse : #{urep.inspect}"
        urep
      end
    end


  end #/Question
end #/Quiz
