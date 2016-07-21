# encoding: UTF-8
class ::Quiz
  class Question

    # Options par défaut
    def type_default
      @type_default ||= 'Orv'
    end

    # Dans les options (1er bit) le type de question (pas encore utilisé)
    def type_f
      @type_f ||= type[0]
    end
    # Dans les options (2e bit) le nombre de choix, un seul ('r' comme
    # 'radio') ou plusieurs ('c' comme 'checkbox')
    def type_c
      @type_c ||= type[1]
    end
    # Dans les options, le type l'alignement ('v' pour vertical, 'h' pour
    # horizontal ou 'm' pour 'menu')
    def type_a
      @type_a ||= type[2]
    end

  end #/Question
end #/Quiz
