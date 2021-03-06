# encoding: UTF-8
=begin

  Module de méthodes pour l'affichage des questions du questionnaire

=end
class Quiz
  class Question

    def evaluation?
      @do_evaluation ||= begin
        v = quiz.evaluation?
        debug "Quiz::Question#evaluation? est #{v.inspect}"
        v
      end
    end
    def exergue_reponses_manquantes?
      @do_exergue_reponses_manquantes || quiz.exergue_reponses_manquantes?
    end

    # Code HTML d'affichage de la question
    # Retourne le DIV contenant la question
    #
    # Son style peut varier si c'est un affichage de résultat
    #
    # Rappels :
    #   evaluation?
    #     est mis à true s'il faut faire l'évaluation des résultat
    #     donné (quand ils ont été donnés). Lorsqu'il manque
    #     des réponses, par exemple, il ne faut pas faire l'évaluation
    #     mais seulement indiquer les réponses manquantes.
    #   exergue_reponses_manquantes?
    #       Mis à true quand on doit simplement indiquer les réponses
    #       manquante.
    def output
      c = String.new
      c << question_formated.in_div(class: 'q', id: "q-#{id}-question")
      # Les indications éventuelles sur la question
      indication.nil? || c << indication.in_div(class: 'indication')
      c << ul_reponses
      c << div_raison if ureponse && !ureponse[:is_good]
      c.in_div(id: "question-#{id}", class: "question #{class_output}".strip)
    end

    def question_formated
      @question_formated ||= begin
        if question != nil
          question.formate_balises_propres
        else
          # Problème grave de question absente
          # ----------------------------------
          # On essaie de construire les données extra
          extra_data =
            begin
              "ID quiz (dans la table quiz) : #{quiz.id} / ID question : #{id}"
            rescue Exception => e
              "Impossible de définir les données extra (id de la question, etc) : #{e.message}."
            end
          send_error_to_admin(
            exception: 'Question Quiz non définie dans #question_formated',
            from: __FILE__,
            file: 'objet/quiz/lib/required/quiz/question/helper.rb',
            extra: extra_data
          )
          "PROBLÈME QUESTION ##{id} (le problème a été signalé à l'administration)"
        end
      end
    end

    # La classe générale de la question en fonction des réponses
    # qui ont peut-être été données
    #
    def class_output
      if ureponse == nil
        # Pas de réponse donnée à cette question. Ça peut correspondre à
        # un simple affichage du questionnaire ou une réponse oubliée
        if exergue_reponses_manquantes?
          'bad'
        else
          ''
        end
      elsif evaluation?
        ureponse[:is_correct] ? 'good' : 'bad'
      end
    end

    # Code HTML de la liste des réponses
    def ul_reponses
      class_css = ['r', type_a]
      lireponses = Array.new
      hreponses.each_with_index do |hreponse, irep|

        # Cette réponse est-elle sélectionnée par l'user ?
        is_selection_user = !!(ureponse && ureponse[:rep_index].include?(irep))

        uselection = (ureponse && ureponse[:rep_index].include?(irep))

        hreponse.merge!(index: irep, type: type_c, uselection: uselection)

        if evaluation?
          # Si c'est une correction (ureponse != nil), il faut indiquer si
          # la réponse courante est une bonne réponse ou une mauvaise
          # réponse.
          # is_correct peut avoir trois valeurs :
          #   true      C'est la bonne valeur à mettre en exergue
          #   false     C'est la mauvaise valeur choisie par l'user
          #   nil       C'est une mauvaise valeur quelconque, non
          #             choisie par l'user.
          if ureponse
            is_good_reponse =
              case ureponse[:type]
              when :checkbox, 'checkbox'  then ureponse[:better_reps].include?(irep)
              when :radio, 'radio'        then ureponse[:good_rep] == irep
              end
            type_reponse =
              if is_good_reponse
                is_selection_user ? :good_selected : :good_notselected
              elsif is_selection_user
                :bad_selected
              else
                :bad_notselected
              end
            # debug "Réponse #{irep} : is_good_reponse est #{is_good_reponse.inspect} / type_reponse = #{type_reponse.inspect}"
            hreponse.merge!(type_reponse: type_reponse)
          end
        end
        # On construit le LI de la réponse et on l'ajoute à la quesiton
        lireponses << Reponse.new(self, hreponse).output
      end
      # On mélange les réponses, sauf si on doit les garder
      # dans l'ordre
      keep_ordre_reponses? || lireponses = lireponses.shuffle.shuffle
      lireponses.join('').in_ul(class: class_css.join(' '))
    end

    # Retourne le code HTML de la raison
    #
    # Note : cette méthode n'est appelée que lorsque c'est une
    # correction et que la réponse est mauvaise.
    #
    def div_raison
      raison != nil && evaluation? || ( return '' )
      (raison.formate_balises_propres.deserb).in_div(class: 'raison')
    end

    # ---------------------------------------------------------------------
    #   Quiz::Question::Reponse
    # ---------------------------------------------------------------------
    class Reponse

      # Instance {Quiz::Question} de la question dont c'est la
      # réponse
      attr_reader :question

      # Données de la réponse (:lib, :pts, :index, :type)
      attr_reader :data

      def initialize question, data
        @question = question
        @data     = data
      end

      # Code HTML de la réponse
      def output
        if checkbox?
          libelle.in_checkbox(
            name:     "#{question.quiz.prefix_reponse}[rep#{question.id}_#{index}]",
            id:       "#{question.quiz.prefix_reponse}_rep#{question.id}_#{index}_",
            checked: selection_user?
          )
        else
          libelle.in_radio(
            name:     "#{question.quiz.prefix_reponse}[rep#{question.id}]",
            id:       "#{question.quiz.prefix_reponse}_rep#{question.id}_#{index}",
            value:    index.to_s,
            checked:  selection_user?
            )
        end.in_li(id: "q-#{question.id}-r-#{index}", class: class_reponse)
      end

      # La classe en fonction du fait que c'est une bonne
      # réponse ou non (seulement quand c'est une correction)
      def class_reponse
        case @data[:type_reponse]
        when :good_selected     then 'good'
        when :good_notselected  then 'goodbad'
        when :bad_selected      then 'bad'
        else nil
        end
      end

      def index   ; @index    ||= data[:index]  end
      def libelle ; @libelle  ||= data[:lib]    end
      def points  ; @points   ||= data[:pts]    end
      def type    ; @type     ||= data[:type]   end

      def checkbox?
        @is_checkbox = type == 'c' if  @is_checkbox === nil
        @is_checkbox
      end
      def radio?
        @is_radio = type == 'r' if  @is_radio === nil
        @is_radio
      end

      # True si l'user l'a sélectionné
      def selection_user?
        @data[:uselection] == true
      end

    end
  end #/Question
end
