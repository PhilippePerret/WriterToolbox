# encoding: UTF-8
class Unan
class Quiz

  # Les réponses de l'auteur
  #
  # Mais noter que cette propriété est invoquée aussi à la
  # construction du questionnaire, que ce soit pour les
  # corrections ou non, pour simplifier le code. C'est le code
  # qui est par exemple transmis à javascript pour remettre les
  # réponses qui ont été fournies par l'user.
  def reponses_auteur
    @reponses_auteur ||= begin
      quiz = auteur.table_quiz.get(where:{quiz_id: id, program_id: auteur.program_id})
      r = quiz[:reponses]
      debug "reponses de quiz #{id} : #{r.inspect}:#{r.class}"
      r
    end
  end

end #/Quiz
end #/Unan
