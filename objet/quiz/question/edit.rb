# encoding: UTF-8
raise_unless_admin

page.add_javascript Dir["#{Quiz.folder_lib}/js/**/*.js"]
page.add_css Dir["#{Quiz.folder_lib}/css/**/*.css"]


def question_id
  @question_id ||= site.current_route.objet_id
end
def question
  @question ||= Quiz::Question.new(nil, question_id)
end

case param(:operation)
when 'save_data_question_quiz'
  # Enregistrement de la question modifiée
  question.save
end
