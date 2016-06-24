# encoding: UTF-8
class Unan
class Quiz


  # Méthode appelée par la vue quiz/show.erb, c'est-à-dire lorsque
  # l'user veut revoir un de ses quiz.
  #
  # Noter que lorsque le quiz est "re-usable" (multi?) il peut
  # être recommencé.
  #
  def output_archives
    @for_correction = true
    code_corrections_et_commentaires
  end

  # {StringHtml} Retourne le code HTML pour afficher
  # le questionnaire.
  # Ce code est enregistré dans la propriété :output
  # dans la base de données, pour accélérer.
  # Si +forcer+ est true, on force la construction du questionnaire
  # même si la donnée output est définie dans la base. C'est utilisé
  # par l'édition pour actualiser chaque fois.
  # Noter que puisque la méthode get_all est appelée en mode édition,
  # ce output est défini. C'est pourquoi il faut mettre le forcer et
  # le out_of_date? avant de tester @output contre nil.
  def output forcer = false
    unless_not_exists
    @output = nil if forcer || out_of_date?
    @output ||= begin
      (forcer || get(:output).empty?) ? build : get(:output) +
      code_for_regle_reponses
    end
  end

end #/Quiz
end #/Unan
