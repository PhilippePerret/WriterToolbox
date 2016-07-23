# encoding: UTF-8
=begin

  Méthodes pour les options du quiz

=end
class Quiz

  # Valeurs des bits d'options
  OPTIONS = {
    0 => {hname: 'courant', description: '1: quiz courant, 0: pas courant'},
    1 => {hname: 'aléatoire', description: '1: questions dans un ordre aléatoire, 0: questions dans ordre prédéfini'}
  }

  # 1er bit des options
  def current?
    options[0].to_i == 1
  end

  # 2e bit des optionis
  def aleatoire?
    options[1].to_i == 1
  end

  # Bits 3 à 5 des options ('-' mis pour '0')
  #
  # NIL s'il n'y a pas de nombre max.
  # Note : On pourrait aussi dire que c'est le nombre de questions.
  def nombre_max_questions
    @nombre_max_questions ||= begin
      m = options[2..4].gsub(/\-/,'').to_i
      m > 0 ? m : nil
    end
  end



end #/Quiz
