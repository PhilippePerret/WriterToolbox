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
      "[UN QUESTIONNAIRE RÉCENT]"
    else
      Unan::Quiz.new(item_id).as_card(self)
    end
  end
  alias :as_card_relative :as_card

end #/AbsWork
end #/Program
# ---------------------------------------------------------------------
#   Class Unan::Quiz
# ---------------------------------------------------------------------
class Quiz

  attr_reader :awork

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
      output_in_container
    end
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
      boutons_quiz
    ).in_div(class:'work quiz')
  end
  def titre_quiz
    (
      (
        # infos_if_admin +
        type_quiz.in_span(class: 'type')
      ).in_div(class:'fright') +
      self.titre
    ).in_div(class:'titre')

  end

  # Type humain du quiz (affiché en regard du titre)
  def type_quiz
    type == 0 ? 'Type non défini' : TYPES[type][:hname]
  end

  def boutons_quiz
    dbouton = {
      class: 'warning',
      href:  "work/#{awork.id}/start?in=unan/program&wpday=#{awork.pday}&cong=quiz"
    }
    (
      'Démarrer ce questionnaire'.in_a(dbouton)
    ).in_div(class:'buttons')
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
  def output_in_container options = nil
    options ||= {}

    # Note : options[:correction] est utilisé pour les simulations
    @for_correction = true if options[:correction] == true

    if correction?
      # Correction du questionnaire
      code_corrections_et_commentaires
    else
      # Affichage du questionnaire pour remplissage
      form = ''
      form << 'bureau_save_quiz'.in_hidden(name:'operation')
      form << id.in_hidden(name:'quiz[id]', id:"quiz_id-#{id}")
      form << awork.id.in_hidden(name: 'quiz[awork_id]', id: 'quiz_awork_id')
      form << awork.pday.in_hidden(name: 'quiz[awork_pday]', id: 'quiz_awork_pday')
      if work != nil
        form << work.id.to_s.in_hidden(name:'quiz[work_id]', id:"quiz_work_id-#{id}")
      end
      form << output(forcer = !!options[:forcer])
      form_action = options[:simulation] ? "quiz/#{id}/simulation?in=unan_admin" : "bureau/home?in=unan&cong=quiz"
      form << bureau.submit_button("Soumettre le questionnaire", {discret: false, tiny: false})

      html = ""
      html << titre.in_div(class:'titre') unless no_titre?
      html << form.force_encoding('utf-8').in_form(id:"form_quiz_#{id}", class:'quiz', action: form_action)
      html
    end
  end

end #/Quiz
end #/Unan
