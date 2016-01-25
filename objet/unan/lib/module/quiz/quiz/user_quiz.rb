# encoding: UTF-8
=begin

Ce module définit aussi la class User::UQuiz pour les enregistrements
de questionnaires de l'user.

=end
class User

  # Return un {Hash} des instances User::UQuiz avec en clé
  # l'ID du questionnaire et en valeur l'instance.
  # Noter qu'il s'agit bien d'instances User::UQuiz, i.e. les
  # enregistrements pour les RÉPONSES de l'user, pas les
  # enregistrements des quiz eux-même.
  #
  # +filtre+
  #   created_after:    <timestamp>
  #   created_before:   <timestamp>
  #   max_points:       <fixnum>
  #   min_points:       <fixnum>
  #   quiz_id:          <fixnum>
  def quizes filter = nil
    @all_quizes ||= begin
      h = Hash::new
      self.table_quiz.select(colonnes:[:id]).keys.each do |qid|
        h.merge!( qid => UQuiz::new(self, qid) )
      end
      h
    end
    return @all_quizes if filter.nil?
    # Sinon, il y a un filtre à traiter
    expected = @all_quizes.dup

    if filter.has_key?(:quiz_id)
      expected = expected.select{|qid, iquiz| iquiz.quiz_id == filter[:quiz_id]}
    end

    if filter.has_key?(:created_after)
      expected = expected.select{|qid, iquiz| iquiz.created_at >= filter[:created_after] }
    end

    if filter.has_key?(:created_before)
      expected = expected.select{|qid, iquiz| iquiz.created_at <= filter[:created_before] }
    end

    if filter.has_key?(:max_points)
      expected = expected.select{|qid, iquiz| iquiz.points <= filter[:max_points]}
    end

    if filter.has_key?(:min_points)
      expected = expected.select{|qid, iquiz| iquiz.points >= filter[:min_points]}
    end

    expected
  end

  class UQuiz

    include MethodesObjetsBdD

    # {User} Auteur possesseur du quiz
    attr_reader :auteur
    # ID du quiz dans la table de l'auteur
    attr_reader :id

    def initialize auteur, qid
      @auteur = auteur
      @id     = qid
    end

    # ID du questionnaire de référence
    def quiz_id     ; @quiz_id    ||= get(:quiz_id)     end
    def created_at  ; @created_at ||= get(:created_at)  end
    def points      ; @points     ||= get(:points)      end

    # Pour faire une sortie simple qui quiz
    # Elle sert soit pour le bureau, dans le panneau Quiz, quand le
    # questionnaire a été rempli récemment, soit dans la partie qui
    # rassemble tous les questionnaires/travaux exécutés jusque-là
    def output_simple
      "Questionnaire “#{quiz.titre}”"
    end

    def quiz
      @quiz ||= Unan::Quiz::get(quiz_id)
    end

    def table
      @table ||= auteur.table_quiz
    end
  end # /UQuiz
end #/User
