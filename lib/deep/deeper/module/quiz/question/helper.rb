# encoding: UTF-8
=begin

  Module de méthodes pour l'affichage des questions du questionnaire

=end
class Quiz
  class Question

    # Code HTML d'affichage de la question
    def output
      c = String.new
      c << question.in_div(class: 'q', id: "q-#{id}")
      indication.nil? || c << indication.in_div(class: 'indication')
      c << ul_reponses
      c.in_div(class: 'question')
    end

    # Code HTML de la liste des réponses
    def ul_reponses
      class_css = ['r', type_a]
      ul = ''
      hreponses.each_with_index do |hreponse, ireponse|
        hreponse.merge!(index: ireponse, type: type_c)
        ul << Reponse.new(self, hreponse).output
      end
      ul.in_ul(class: class_css.join(' '))
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
          libelle.in_checkbox(name: "reponse-#{question.id}-#{index}")
        else
          libelle.in_radio(name: "reponse-#{question.id}", value: index.to_s)
        end.in_li
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

    end
  end #/Question
end
