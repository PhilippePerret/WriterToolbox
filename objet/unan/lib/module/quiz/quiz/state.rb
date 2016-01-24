# encoding: UTF-8
class Unan
class Quiz

  def exist?
    Unan::table_quiz.count(where:{id: id}) > 0
  end

  # Return true si le questionnaire valide les acquis, i.e. s'il
  # est supérieur au minimum de points requis.
  # Cette méthode est appelée quand l'on soumet le formulaire, mais
  # elle doit fonctionner aussi d'après les données enregistrées. C'est
  # la raison pour laquelle on calcule user_points si nécessaire.
  def questionnaire_valided?

    # Nombre de points marqués par l'auteur pour ce quiz
    @user_points ||= begin
      res = user.table_quiz.select(where:"quiz_id = #{id}", order:"created_at DESC", limit:1, colonnes:[:points]).values.first
      raise "Les données pour ce questionnaire sont introuvables…" if res.nil?
      res[:points]
    end

    # Le jour programme courant, pour savoir quelle note il
    # faut avoir au minimum pour considérer le questionnaire
    # comme réussi.
    pday_courant = user.program.current_pday(:nombre).freeze # => p.e. 36

    # Tous les deux mois programme, il faut ajouter un points.
    # Donc il faut avoir 12 pendant les 2 premiers mois, 13 les
    # mois 3-4, 14 les mois 5-6, 15 les mois 7-8, 16 les mois 8-9,
    # 17 les mois 10-11 et 18 le dernier mois.
    minimum = 12 + pday_courant / 60

    # La note sur 20 pour ce questionnaire
    note_sur_vingt = note_sur_20_for(@user_points)

    # Le nombre de jours au-dessus (positif) de la moyenne
    # ou en dessous (négatif)
    @ecart_moyenne = note_sur_vingt - minimum

    # La moyenne pour ce questionnaire doit être supérieure au
    # minimum du moment
    note_sur_vingt > minimum

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
      updates = Unan::table_questions.select(colonnes: [:updated_at], where: "id IN (#{qids})").values
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
