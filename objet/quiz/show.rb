# encoding: UTF-8
=begin

  Module permettant l'affichage du quiz

=end

case param(:operation)
when 'evaluate_quiz' # soumission du quiz
  quiz.evaluate
end
