# encoding: UTF-8
=begin

  Module de méthodes qui permettent de définir la question.

  Ce module est réservé à un niveau d'administrateur supérieur.

=end
if user.manitou?

  class ::Quiz
    class Question
      class << self
        # Méthode principale appelée quand on soumet le formulaire
        # pour enregistrer la question.
        # Noter que ça passe d'abord par le fichier helper_admin du
        # questionnaire (méthode `form`) qui appelle cette méthode
        # en fournissant son instance Quiz.
        #
        # Toutes les données sont contenues dans le paramètre :question
        #
        def save_data_question quiz
          # On ne peut pas enregistrer de question pour un quiz
          # qui n'est pas encore enregistré
          quiz.exist? || raise('Il faut enregistrer le questionnaire avant de pouvoir lui affecter une question.')
          qid = param(:question)[:id].nil_if_empty
          qid.nil? || qid = qid.to_i
          Question.new(quiz, qid).save
        rescue Exception => e
          debug e
          error e.message
        end
      end #/<< self

      # ---------------------------------------------------------------------
      #   INSTANCE
      # ---------------------------------------------------------------------

      # Méthode principale qui sauve la question
      def save
        prepare_and_check_data2save || return
        if exist?
          table.update(id, data2save)
          flash "Question ##{id} actualisée."
        else
          @id = table.insert(data2save.merge(created_at: NOW))
          flash "Question ##{id} créée avec succès."
        end
      end

      def data2save
        @data2save ||= begin
          {
            question:     question,
            groupe:       quiz.groupe,
            reponses:     reponses,
            type:         type,
            raison:       raison,
            indication:   indication,
            updated_at:   NOW
          }
        end
      end

      # Prépare les données de la question en les mettant dans les
      # variables après les avoir checkées.
      #
      # Noter que l'identifiant a été traité avant, dans la méthode
      # de classe qui permet de créer/updater la question ci-dessus.
      #
      def prepare_and_check_data2save
        v = data_param[:question].nil_if_empty
        v != nil || raise('La question doit être fournie.')
        @question = v
        nombre_reponses = data_param[:nombre_reponses].to_i
        nombre_reponses > 0 || raise('Il faut impérativement donner des réponses')
        reponses = Array.new
        (1..nombre_reponses).each do |ireponse|
          dreponse = data_param["reponse_#{ireponse}".to_sym]
          lib_reponse = dreponse[:libelle].nil_if_empty
          lib_reponse != nil || next
          pts_reponse = dreponse[:points].nil_if_empty
          reponses << {lib: lib_reponse, pts: pts_reponse}
        end
        reponses.count > 0 || raise('Il faut impérativement donner des réponses avec libellés.')
        @reponses   = reponses.to_json
        @raison     = data_param[:raison].nil_if_empty
        @indication = data_param[:indication].nil_if_empty
      rescue Exception => e
        debug e
        error e.message
      else
        true
      end

      def data_param
        @data_param ||= param(:question)
      end
    end #/Question
  end

end # if manitou
