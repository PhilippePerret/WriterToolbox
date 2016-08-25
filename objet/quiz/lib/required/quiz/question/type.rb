# encoding: UTF-8
class ::Quiz
  class Question

    # Options (type) par défaut
    def type_default
      @type_default ||= '0rv0'
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

    # Pour savoir si la question est masquée, i.e. si elle ne doit pas
    # apparaitre dans la liste de toutes les questions, pour alléger
    # l'affichage de cette liste.
    def masked?
      @is_masked ||= type[3].to_i == 1
    end

    # BIT 5 pour savoir s'il faut garder l'ordre des réponses
    # Par défaut, les réponses sont toujours mélangées, ce qui produit
    # forcément un affichage aléatoire. Mais parfois, il faut les garder
    # dans l'ordre.
    def keep_ordre_reponses?
      @is_keep_ordre_reponses ||= type[4].to_i == 1
    end

  end #/Question
end #/Quiz
