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

  def current?
    options[0].to_i == 1
  end

  def aleatoire?
    options[1].to_i == 1
  end



end #/Quiz
