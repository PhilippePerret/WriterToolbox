# encoding: UTF-8
=begin
  Extension de la class Unan::Program::AbsWork spécialement
  pour l'onglet QUIZ du bureau de l'auteur
=end
class Unan
class Program
class AbsWork

  def as_card options = nil
    options ||= Hash.new
    recent_quiz = !!options.delete(:as_recent)
    if recent_quiz
      UnanQuiz.new(item_id).as_recent_card(self, options)
    else
      UnanQuiz.new(item_id).as_card(self, options)
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

  # Défini par #as_card
  def awork;        @awork                          end
  def awork_id;     @awork_id     ||= awork.id      end
  def auteur;       @auteur       ||= user          end

  # Le jour-programme de ce quiz (un même quiz peut être programmé
  # à des jours-programme différents)
  # Dans l'ordre, si le travail de l'auteur est défini (work), on le
  # prend dedans, si le travail
  def quiz_pday
    @quiz_pday ||= begin
      if @work
        work.pday
      elsif @awork
        awork.pday
      end || param(:pday)
    end
  end


  # Méthode produisant la "carte" du questionnaire pour le
  # bureau de l'auteur, c'est-à-dire affichant :
  #   - un bloc pour démarre le questionnaire
  #   - le questionnaire lui-même
  #   - l'affichage des réponses données au questionnaire
  #
  def as_card awork = nil, options = nil
    awork.instance_of?(Unan::Program::AbsWork) || raise('Il faut fournir le travail absolu à la méthode #as_card !')
    @awork = awork
    debug "-> #as_card (awork.class = #{awork.class})"
    res =
      if not_started?
        # Questionnaire non démarré => Un cadre pour le démarrer
        form_start_quiz
      else
        output(options)
      end
    debug "<- #as_card (awork.class = #{awork.class})"
    return res
  end

  def as_recent_card awork = nil
    awork.instance_of?(Unan::Program::AbsWork) || raise('Il faut fournir le travail absolu à la méthode #as_card !')
    @awork = awork
    form_recent_quiz
  end

  def not_started?
    awork_id != nil && quiz_pday != nil || (return true)
    # awork_id != nil  || (return !error('Impossible de savoir si le quiz est démarré : pas d’identifiant de work absolu défini.'))
    # quiz_pday != nil || (return !error('Impossible de savoir si le quiz est démarré : pas de jour-programme précisé.'))
    drequest = {
      where: "abs_work_id = #{awork_id} AND abs_pday = #{quiz_pday}",
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
    debug "-> #output (options = #{options.inspect})"
    options ||= Hash.new
    html = String.new
    html << "<h5 class='titre'>#{titre}</h5>"
    # Action
    # Noter que c'est dans cette valeur qu'on passe l'UnanQuiz courant
    quiz.form_action        = "bureau/home?in=unan&cong=quiz&unanquiz=#{id}&work=#{work.id}"
    debug "quiz.form_action : #{quiz.form_action}"
    quiz.form_operation     = 'bureau_save_quiz'
    quiz.form_submit_button = 'Soumettre'
    quiz.no_pre_description =     true
    quiz.no_post_description=     true
    quiz.no_message_note_finale=  true

    # === ÉVALUATION DU QUESTIONNAIRE
    if options[:evaluate]
      quiz.evaluate
      unless quiz.is_reshown || quiz.error_evaluation
        # On peut demander la construction du rapport pour produire
        # la note finale.
        quiz.report
        # Ajout des points à l'auteur
        auteur.add_points quiz.unombre_points
        flash "Nombre de points marqués : #{quiz.unombre_points}"
        # Association du work à l'identifiant de rangée de résultat
        # Pour l'obtenir à nouveau, on pourra faire :
        #   site.require_objet 'quiz'
        #   quiz = Quiz.new(<id>, 'unan')
        #   quiz.table_resultats.get(work.item_id)
        debug "quiz.resultats_row_id : #{quiz.resultats_row_id.inspect}"
        work.set(item_id: quiz.resultats_row_id)
      else
        if quiz.error_evaluation
          debug "Une erreur est survenue (#{quiz.error_evaluation}), impossible d'enregistrer le nombre de points"
        else
          debug "Reshown du questionnaire => pas de points enregistrés."
        end
      end
    end

    html << quiz.output
    debug "<- #output"
    # html << form.force_encoding('utf-8').in_form(id:"form_quiz_#{id}", class:'quiz', action: form_action)
    html
  end
  # /output

  # Travail propre ({Unan::Program::Work}) correspondant
  # à ce questionnaire.
  def work
    @work ||= get_work_of_quiz
  end

  # Récupère le Unan::Program::Work du quiz courant
  #
  # Définit aussi, si besoin était, le quiz_pday
  def get_work_of_quiz
    wid =
      if param(:work)
        debug "-> on prend le work dans param(:work) (#{param(:work)})"
        param(:work).to_i # => à mettre dans wid
      else
        # Tous les travaux correspondant au travail absolu
        drequest = {
          program_id: auteur.program.id, abs_work_id: awork_id,
          colonnes: [], order: 'created_at DESC'
        }
        hworks = auteur.table_works.select(drequest)

        # S'il n'y en a qu'un seul, super, c'est celui-là
        # Sinon, soit on prend celui correspondant au pday demandé, soit
        # si le pday n'est pas récupérable, on prend le dernier
        # Notez que cette méthode définira toujours @quiz_pday
        if hworks.count > 1 && quiz_pday
          hworks.select{|h| h[:abs_pday] == quiz_pday}[:id]
        else
          hworks.first[:id]
        end
      end
    w = Unan::Program::Work.new(auteur, wid)
    quiz_pday != nil || @quiz_pday = w.pday
    return w
  end
  #/get_work_of_quiz

end #/Quiz
end #/Unan
