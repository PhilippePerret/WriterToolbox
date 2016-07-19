# encoding: UTF-8
=begin

  Méthodes pour les options du quiz

=end
class Quiz

  OPTIONS = {
    0 => {hname: 'aléatoire', description: '1: questions dans un ordre aléatoire, 0: questions dans ordre prédéfini'}
  }

  def aleatoire?
    options[0].to_i == 1
  end


end #/Quiz
