# encoding: UTF-8
class Unan
class Quiz

  def exist?
    Unan::table_quiz.count(where:{id: id}) > 0
  end

  # ---------------------------------------------------------------------
  #   Options
  #
  # Définir dynamiquement toutes les méthodes d'options
  # description?, no_titre? etc.
  # Cf. la constante OPTIONS
  OPTIONS.each do |k, dk|
    define_method "#{k}?" do
      options[dk[:bit]].to_i == 1
    end
  end

  # / Fin des options
  # ---------------------------------------------------------------------

  def out_of_date?; !output_up_to_date? end

  # Retourne true si le questionnaire est à jour
  # Il ne l'est pas si une de ses questions a été modifiée
  # depuis sa dernière création
  def output_up_to_date?
    if @is_output_up_to_date === nil
      qids = questions_ids.split(' ').join(', ')
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
