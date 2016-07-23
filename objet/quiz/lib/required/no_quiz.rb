# encoding: UTF-8
=begin

  Class NoQuiz
  ------------
  Permet de gérer très simplement l'absence de quiz.

=end
# Utile quand aucun questionnaire n'est défini, on crée une
# instance NoQuiz pour la mettre dans `quiz` pour gérer facilement
# l'affichage, sans conditions
class NoQuiz
  def output
    'Houps ! Questionnaire inconnu… :-('.in_div(class: 'big air warning') +
    (OFFLINE ? "(#{Quiz.error})".in_p(class: 'tiny') : '')
  end
  def form
    ''
  end
end
