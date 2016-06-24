# encoding: UTF-8
class Unan
class Quiz

  # {Array} Retourne la liste des instances Unan::Quiz::Question des
  # questions du questionnaires.
  def questions
    @questions ||= begin
      sorted_questions_ids.collect do |qid|
        Question::new(qid, self.id)
      end
    end
  end

  # {Array} La liste des IDs des questions du questionnaire
  # Si desordre?, alors l'ordre initial est shufflé
  def sorted_questions_ids
    @sorted_questions_ids ||= begin
      arr = questions_ids.split(' ').collect { |qid| qid.to_i }
      arr = arr.shuffle.shuffle.shuffle if desordre?
      arr
    end
  end

end #/Quiz
end #/Unan
