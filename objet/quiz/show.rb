# encoding: UTF-8
=begin

  Module permettant l'affichage du quiz

=end

class Quiz

  # Méthode principale appelée pour afficher le
  # questionnaire
  def output
    page.add_javascript Dir["#{Quiz.folder_lib}/js/user/**/*.js"]
    page.add_css Dir["#{Quiz.folder_lib}/css/user/**/*.css"]
    build
  end

end

case param(:operation)
when 'evaluate_quiz' # soumission du quiz
  quiz.evaluate
end
