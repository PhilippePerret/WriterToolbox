# encoding: UTF-8
=begin

  Module de méthodes pour l'affichage des questions du questionnaire

=end
class Quiz
  class Question

    # Code HTML d'affichage de la question
    # Retourne le DIV contenant la question
    #
    # Son style peut varier si c'est une affichage de résultat
    #
    def output
      c = String.new
      c << question.in_div(class: 'q', id: "q-#{id}")
      # Les indications éventuelles sur la question
      indication.nil? || c << indication.in_div(class: 'indication')
      c << ul_reponses
      c << div_raison if ureponse && !ureponse[:is_good]
      c.in_div(class: "question #{class_output}".strip)
    end

    # La classe générale de la question en fonction des réponses
    # qui ont peut-être été données
    #
    def class_output
      ureponse != nil || ( return '' )
      ureponse[:is_good] ? 'good' : 'bad'
    end

    # Code HTML de la liste des réponses
    def ul_reponses
      class_css = ['r', type_a]
      ul = ''
      hreponses.each_with_index do |hreponse, ireponse|
        # Cette réponse est-elle sélectionnée par l'user ?
        uselection = (ureponse && ureponse[:rep_index].include?(ireponse))

        hreponse.merge!(index: ireponse, type: type_c, uselection: uselection)

        # Si c'est une correction (ureponse != nil), il faut indiquer si
        # la réponse courante est une bonne réponse ou une mauvaise
        # réponse.
        # is_good peut avoir trois valeurs :
        #   true      C'est la bonne valeur à mettre en exergue
        #   false     C'est la mauvaise valeur choisie par l'user
        #   nil       C'est une autre valeur mauvaise
        if ureponse
          best_reps = ureponse[:best_rep] || []
          good_rep  = ureponse[:good_rep]
          is_good   = (good_rep == ireponse || best_reps.include?(ireponse))
          case uselection
          when true
            is_good = is_good ? true : false
          when false
            is_good = is_good ? true : nil
          end
          hreponse.merge!(is_good: is_good)
        end

        # On construit le LI de la réponse et on l'ajoute à la quesiton
        ul << Reponse.new(self, hreponse).output
      end
      ul.in_ul(class: class_css.join(' '))
    end

    # Retourne le code HTML de la raison
    #
    # Note : cette méthode n'est appelée que lorsque c'est une
    # correction et que la réponse est mauvaise.
    #
    def div_raison
      raison != nil || ( return '' )
      raison.formate_balises_propres.in_div(class: 'raison')
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
            selected: selection_user?
          )
        else
          libelle.in_radio(
            name: "#{question.quiz.prefix_reponse}[rep#{question.id}]",
            value: index.to_s,
            checked: selection_user?
            )
        end.in_li(class: class_reponse)
      end

      # La classe en fonction du fait que c'est une bonne
      # réponse ou non (seulement quand c'est une correction)
      def class_reponse
        case @data[:is_good]
        when NilClass then nil
        when FalseClass then 'bad'
        when TrueClass  then 'good'
        else raise ":is_good a une valeur inconnue… Glourps…"
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

      # True si c'est une bonne réponse
      def bonne_reponse?
        @data[:is_good] == true
      end

      # True si l'user l'a sélectionné
      def selection_user?
        @data[:uselection] == true
      end

    end
  end #/Question
end
