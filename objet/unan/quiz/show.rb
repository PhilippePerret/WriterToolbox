# encoding: UTF-8
# site.require_objet 'unan'
Unan::require_module 'quiz'

# ---------------------------------------------------------------------
# On détermine :
#   - master_quiz     L'instance Unan::Quiz du questionnaire absolu
#   - user_quiz       L'instance User::UQuiz du question de l'user qui
#                     correspond à ce quiz.
#

# Le quiz absolu
# Pour qu'il soit vu "au travers" du quiz de l'auteur ci-dessous, on
# utilise `uquiz.quiz` pour le récupérer
def master_quiz
  @master_quiz ||= user_quiz.quiz
end

# Le quiz propre à l'auteur
def user_quiz
  @user_quiz ||= begin
    auteur = param(:user_id) ? User::get(param(:user_id).to_i) : user
    qid = site.current_route.objet_id.to_i
    User::UQuiz::get( qid, auteur )
  end
end
