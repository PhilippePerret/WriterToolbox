# encoding: UTF-8
=begin
  Simplement pour rediriger un user abonné vers la liste de tous les
  quiz.
=end
if user.authorized?
  redirect_to 'quiz/list'
end
