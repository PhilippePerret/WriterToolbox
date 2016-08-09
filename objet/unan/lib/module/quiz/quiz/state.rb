# encoding: UTF-8
class Unan
class Quiz

  # Retourne true si le questionnaire existe
  def exist?
    Unan::table_quiz.count(where: { id: id }, colonnes: []) > 0
  end

  # Retourne true si l'auteur possède déjà ce
  # questionnaire dans sa table des quiz. Attention, s'il suit
  # plusieurs programmes, il peut s'agit d'un ancien programme
  def auteur_has_this_quiz?
    drequest = {
      where:    {quiz_id: id, program_id: auteur.program.id},
      colonnes: []
    }
    auteur.table_quiz.count(drequest) > 0
  end

  # Retourne true si c'est un affichage du questionnaire pour
  # correction.
  # Les changements sont les suivants :
  #   - pas de bouton pour soumettre le questionnaire
  #   - on laisse le code JS pour régler les réponses
  #   - mis en exergue des bonnes et mauvaises réponses
  def correction?
    !!@for_correction
  end
  alias :for_correction? :correction?

  # Return true si le questionnaire valide les acquis, i.e. s'il
  # est supérieur au minimum de points requis.
  # Cette méthode produit aussi :
  #     @ecart_moyenne
  # qui contient l'écart de note avec la moyenne, en positif si au-dessus
  # et en négatif dans le cas contraire. Permet d'adapter le texte.
  # Cette méthode est appelée quand l'on soumet le formulaire, mais
  # elle doit fonctionner aussi d'après les données enregistrées. C'est
  # la raison pour laquelle on calcule auteur_points si nécessaire.
  def questionnaire_valided?

    # La moyenne pour ce questionnaire doit être supérieure au
    # minimum du moment.
    # Note : C'est cette valeur qui doit être retournée.
    auteur_note_sur_vingt > moyenne_minimum

  end

  def out_of_date?; !output_up_to_date? end

  # Retourne true si le questionnaire est à jour
  # Il ne l'est pas si une de ses questions a été modifiée
  # depuis sa dernière création
  def output_up_to_date?
    return true unless user.admin?
    unless_not_exists
    if @is_output_up_to_date === nil
      qids = (questions_ids || "").split(' ').join(', ')
      @is_output_up_to_date = true
      updates = Unan::table_questions.select(colonnes: [:updated_at], where: "id IN (#{qids})")
      updates.each do |h|
        update = h[:updated_at]
        # Si on trouve une question qui a été modifiée après
        # ce questionnaire, on retourne false, le questionnaire
        # n'est pas à jour.
        if update > updated_at
          @is_output_up_to_date = false
          break
        end
      end
    end
    @is_output_up_to_date
  end

end #/Quiz
end #/Unan
