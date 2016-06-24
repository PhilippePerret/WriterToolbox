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
  def auteur_reponses
    @auteur_reponses ||= begin
      uquiz = auteur.quizes(quiz_id: id).values.last
      uquiz.nil? ? {} : uquiz.reponses
    end
  end

end #/Quiz
end #/Unan
