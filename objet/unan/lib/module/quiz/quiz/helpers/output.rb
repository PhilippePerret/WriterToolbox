# encoding: UTF-8
class Unan
class Quiz


  # = main =
  #
  # Méthode principale qui construit le retour à afficher
  # pour l'utilisateur après sa soumission du questionnaire, que
  # cette soumission ait été correcte ou que le questionnaire
  # soumis soit inconforme.
  #
  # Ce retour est composé principalement de deux choses :
  #   - l'affichage des résultats avec les bonnes réponses
  #     en vert et les mauvaises en rouge et l'affichage des
  #     raisons des résultats.
  #   - tous les textes par rapport à ces résultats.
  #
  def commented_output
    if for_correction?
      texte_per_quiz_type     +
      texte_per_ecart_moyenne +
      detail_bonnes_reponses    # utilise la méthode `build`
    else
      # Un ré-affichage du questionnaire, mais où il
      # faut insérer les réponses déjà données. On force la
      # refabrication du code pour tenir compte des réponses
      # données par l'auteur.
      output(forcer = true)
    end
  end

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
      c = (forcer || get(:output).empty?) ? build : get(:output)
      c + code_for_regle_reponses
    end
  end

end #/Quiz
end #/Unan
