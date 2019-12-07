# encoding: UTF-8
=begin

  On ne peut pas utiliser la class Quiz::Question qui concerne une question
  dans un quiz particulier. Ici, la classe concerne n'importe quelle question
  hors de tout quiz.

=end
class QuestionQuiz

  class << self
    # Retourne la liste des questions en fonction du filtre voulu
    # C'est une liste d'instances QuestionQuiz
    def selection
      Quiz.table_questions.select.collect{|h|QuestionQuiz.new(h)}.select do |ques|
        if ques.hors_list?
          # On retire toujours les questions hors-liste
          false
        else
          if filtre[:mot]
            debug "'#{filtre[:mot]}' cherché dans #{ques.question}"
            !!ques.question.match(/#{Regexp.escape filtre[:mot]}/i)
          else
            true
          end
        end
      end
    end
    def filtre
      @filtre ||= begin
        h = param(:filtre) || Hash.new
        h[:mot] = h[:mot].nil_if_empty
        h
      end
    end
  end #/<< self

  # {Hash} Les données fournies à l'instanciation
  attr_reader :data

  attr_reader :id, :question, :reponses, :type
  attr_reader :groupe, :indication, :raison

  def initialize data
    @data = data
    data.each{|k,v| instance_variable_set("@#{k}", v)}
    # debug "data question : #{data.inspect}" if id == 10
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------
  def as_li
    if hors_list?
      ''
    else
      question_in_li
    end
  end
  def question_in_li
    (
      boutons_editions +
      id_in_span +
      question
    ).in_li(class: 'q')
  end
  def id_in_span
    "[#{id}]".in_span(class: 'id')
  end
  def boutons_editions
    (
      '[edit]'.in_a(href: "question/#{id}/edit?in=quiz", target: :new)
    ).in_span(class: 'btns')
  end

  def hors_list?
    @is_hors_list ||= type[3].to_i == 1
  end
end #/QuestionQuiz
