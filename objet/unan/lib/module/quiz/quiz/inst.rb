# encoding: UTF-8
class Unan
class Quiz

  include MethodesMySQL

  # Identifiant unique du questionnaire
  attr_reader :id


  def initialize id
    @id = id
  end

  # ---------------------------------------------------------------------
  #   Data enregistrées
  # ---------------------------------------------------------------------
  def titre         ; @titre          ||= get(:titre)         end
  def type          ; @type           ||= get(:type)          end
  def questions_ids ; @questions_ids  ||= get(:questions_ids) end
  def description   ; @description    ||= get(:description)   end
  def options       ; @options        ||= get(:options)       end
  def points        ; @points         ||= get(:points)        end

  # ---------------------------------------------------------------------
  #   Données volatiles
  # ---------------------------------------------------------------------
  def human_type
    @human_type ||= TYPES[type][:hname]
  end

  def auteur
    return nil if user.admin?
    @auteur ||= user
  end
  def auteur= quser
    @auteur = quser
  end

  # Travail propre ({Unan::Program::Work}) correspondant
  # à ce questionnaire.
  def work
    @work ||= begin
      if awork.nil? && awork_id.nil?
        # Se produit lorsque c'est une édition du
        # quiz ou lorsque le quiz est enregistré pour
        # la première fois.
        nil
      else
        get_work_of_quiz
      end
    end
  end

  # Récupère le Unan::Program::Work du quiz courant
  def get_work_of_quiz
    drequest = {
      where:    {
        abs_work_id:  awork_id || awork.id,
        program_id:   auteur.program.id,
        abs_pday:     awork_pday || awork.pday
      },
      colonnes: Array.new
    }
    wid = auteur.table_works.get(drequest)[:id]
    Unan::Program::Work.new(auteur, wid)
  end

  # Retourne l'User::UQuiz pour ce quiz, qu'il existe ou
  # non.
  # Si +quser+ ({User} qui est l'auteur du questionnaire, n'est pas
  # précisé, c'est l'auteur courant (user) qui est pris en
  # référence.
  def uquiz quser = nil
    User::UQuiz.get(self.id, quser)
  end

  # Retourne le type-validation du questionnaire, qui peut
  # être :renseignements (renseignements et sondage),
  # :simple_quiz (questionnaire à point mais sans validation
  # d'acquis), :validation_acquis (questionnaire à réussir
  # impérativement pour poursuivre)
  def type_validation
    @type_validation ||= TYPES[type][:type_v]
  end

  # {Fixnum|Nil} Nombre de points maximum pour ce questionnaire, ou
  # nil si aucun point n'est à attribuer.
  # Note : Ne tient pas compte de la valeur `points` qui peut être
  # définie optionnellement.
  def max_points
    @max_points ||= begin
      mp = 0
      questions.each { |q| mp += q.max_points unless q.max_points.nil? }
      mp = nil if mp == 0
      mp
    end
  end

  # Retourne les points marqués pour ce quiz, i.e. les points pour les
  # questions s'il y en a + les points spécialement du questionnaire
  def quiz_points
    @quiz_points ||= begin
      pts = 0
      pts += (auteur_points || 0) unless only_points_quiz?
      pts += (points || 0)
      pts
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes de version
  # ---------------------------------------------------------------------
  def previous_version
    @previous_version ||= begin
      previous_version_id.nil? ? nil : Unan::Quiz.new(previous_version_id)
    end
  end
  def next_version
    @next_version ||= begin
      next_version_id.nil? ? nil : Unan::Quiz.new(next_version_id)
    end
  end

  # ---------------------------------------------------------------------
  #   Base de données
  # ---------------------------------------------------------------------
  def table ; @table ||= Unan.table_quiz end

end #/Quiz
end #/Unan
