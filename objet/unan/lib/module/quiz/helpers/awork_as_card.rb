# encoding: UTF-8
=begin
  Extension de la class Unan::Program::AbsWork spécialement
  pour l'onglet QUIZ du bureau de l'auteur
=end
class Unan
class Program
class AbsWork

  def as_card options = nil
    if options[:as_recent]
      UnanQuiz.new(item_id).as_recent_card(self)
    else
      UnanQuiz.new(item_id).as_card(self)
    end
  end
  alias :as_card_relative :as_card

end #/AbsWork
end #/Program

# ---------------------------------------------------------------------
#   Class Unan::UnanQuiz
# ---------------------------------------------------------------------
class UnanQuiz

  # Identifiant du quiz
  attr_reader :id


  attr_reader :awork

  def initialize qid
    @id = qid
  end

  # L'instance Quiz du quiz
  def quiz
    @quiz ||= Quiz.new(id, 'unan')
  end

  # Méthodes-propriétés raccourcis
  def type; @type ||= quiz.type end
  def titre; @titre ||= quiz.titre end
  # Retourne TRUE si c'est l'affichage des résultats auquel
  # il faut procéder. False dans le cas contraire
  def correction?; @is_correction ||= quiz.evaluation? end

  def awork_id;     @awork_id     ||= awork.id      end
  def awork_pday;   @awork_pday   ||= awork.pday    end
  def auteur;       @auteur       ||= user          end


  # Méthode produisant la "carte" du questionnaire pour le
  # bureau de l'auteur, c'est-à-dire affichant :
  #   - un bloc pour démarre le questionnaire
  #   - le questionnaire lui-même
  #   - l'affichage des réponses données au questionnaire
  #
  def as_card awork = nil
    @awork = awork
    if not_started?
      # Questionnaire non démarré => Un cadre pour le démarrer
      form_start_quiz
    else
      output
    end
  end

  def as_recent_card awork = nil
    @awork = awork
    form_recent_quiz
  end

  def not_started?
    awid    = awork_id    || awork.id
    awpday  = awork_pday  || awork.pday
    awid != nil   || (return !error('Impossible de savoir si le quiz est démarré : pas d’identifiant de work absolu défini.'))
    awpday != nil || (return !error('Impossible de savoir si le quiz est démarré : pas de jour-programme précisé.'))
    drequest = {
      where: "abs_work_id = #{awid} AND abs_pday = #{awpday}",
      colonnes:[]
    }
    auteur.table_works.count(drequest) == 0
  end
  def form_start_quiz
    (
      titre_quiz      +
      boutons_start_quiz
    ).in_div(id: "work-#{awork.id}", class:'work quiz')
  end
  def form_recent_quiz
    (
      titre_quiz      +
      boutons_recent_quiz
    ).in_div(id: "work-#{awork.id}", class:'work quiz')
  end
  def titre_quiz
    (
      (
        # infos_if_admin +
        type_quiz.in_span(class: 'type')
      ).in_div(class:'fright') +
      self.titre
    ).in_div(class: 'titre')

  end

  # Type humain du quiz (affiché en regard du titre)
  def type_quiz
    type == 0 ? 'Type non défini' : Quiz::TYPES[type][:hname]
  end

  def boutons_start_quiz
    dbouton = {
      class: 'warning',
      href:  "work/#{awork.id}/start?in=unan/program&wpday=#{awork.pday}&cong=quiz"
    }
    (
      'Répondre à ce questionnaire'.in_a(dbouton)
    ).in_div(class:'buttons')
  end
  def boutons_recent_quiz
    # TODO : RAJOUTER CE BOUTON LORSQU'ON quiz/show SERA OPÉRATIONNEL
    return ''
    dbouton = {
      class:  'btn small',
      href:  "quiz/#{id}/show?in=unan&user_id=#{bureau.auteur.id}",
      target: :new
    }
    return (
      'Revoir ce quiz'.in_a(dbouton)
    ).in_div(class: 'right') # ne pas mettre .buttons, il serait caché
  end


  # = main =
  #
  # Méthode principale appelée par la vue pour afficher le
  # questionnaire, soit en version formulaire, soit en version de
  # correction.
  #
  # {StringHTML} Retourne le code HTML intégral avec le formulaire
  # et les boutons pour soumettre chaque questionnaires
  # +options+
  #   forcer:       Si true, on force la reconstruction du questionnaire
  #   simulation:   Si true, c'est une simulation
  #   evaluate      Si true, on évalue le quiz
  def output options = nil
    options ||= Hash.new
    html = String.new
    html << "<h5 class='titre'>#{titre}</h5>"
    # Action
    # Noter que c'est dans cette valeur qu'on passe l'UnanQuiz courant
    quiz.form_action        = "bureau/home?in=unan&cong=quiz&unanquiz=#{id}"
    quiz.form_operation     = 'bureau_save_quiz'
    quiz.form_submit_button = 'Soumettre'
    quiz.no_pre_description =     true
    quiz.no_post_description=     true
    quiz.no_message_note_finale=  true

    # === ÉVALUATION DU QUESTIONNAIRE
    if options[:evaluate]
      quiz.evaluate
      unless quiz.is_reshown || quiz.error_evaluation
        auteur.add_points quiz.unombre_points
        flash "Nombre de points marqués : #{quiz.unombre_points}"
      else
        if quiz.error_evaluation
          debug "Une erreur est survenue (#{quiz.error_evaluation}), impossible d'enregistrer le nombre de points"
        else
          debug "Reshown du questionnaire => pas de points enregistrés."
        end
      end
    end

    html << quiz.output
    # html << form.force_encoding('utf-8').in_form(id:"form_quiz_#{id}", class:'quiz', action: form_action)
    html
  end
  # /output

  # Travail propre ({Unan::Program::Work}) correspondant
  # à ce questionnaire.
  def work
    @work ||= begin
      w =
        if awork.nil? && awork_id.nil?
          # Se produit lorsque c'est une édition du
          # quiz ou lorsque le quiz est enregistré pour
          # la première fois.
          nil
        else
          get_work_of_quiz
        end
      # Si le travail n'existe pas, il faut certainement le créer ?
      if w == nil
        # ...
      else
        w
      end
    end
  end

  # Récupère le Unan::Program::Work du quiz courant
  def get_work_of_quiz
    drequest = {
      where:    {
        abs_work_id:  awork_id,
        program_id:   auteur.program.id,
        abs_pday:     awork_pday
      },
      colonnes: Array.new
    }
    wid = auteur.table_works.get(drequest)[:id]
    Unan::Program::Work.new(auteur, wid)
  end
  #/get_work_of_quiz

end #/Quiz
end #/Unan
