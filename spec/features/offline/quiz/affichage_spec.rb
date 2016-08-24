# encoding: UTF-8
=begin

  Test de l'affichage d'un quiz quelconque

  Pour le moment, puisqu'il n'existe que le quiz sur le scénodico,
  on utilise celui-là.

=end
feature "Test de l'affichage d'un quiz/questionnaire" do
  before(:all) do
    site.require_objet 'quiz'
    @quiz_courant_data = {id: Quiz.current.id, suffix: Quiz.current.suffix_base}
    puts "Données du quiz courant : #{@quiz_courant_data.inspect}"
  end
  after(:all) do
    # Il faut retirer tous les courants qui ont pu être mis et
    # remettre les valeurs originales
    Quiz.allquiz.each do |iquiz|
      iquiz.current? || next
      next if iquiz.id == @quiz_courant_data[:id] && iquiz.suffix_base == @quiz_courant_data[:suffix]
      iquiz.set(options: iquiz.options.set_bit(0, 0))
      puts "Le quiz #{iquiz.titre} n'est plus en courant"
    end
    Quiz.allquiz_hors_liste.each do |iquiz|
      iquiz.current? || next
      next if iquiz.id == @quiz_courant_data[:id] && iquiz.suffix_base == @quiz_courant_data[:suffix]
      iquiz.set(options: iquiz.options.set_bit(0, 0))
      puts "Le quiz #{iquiz.titre} n'est plus en courant"
    end
  end
  def table_quiz_biblio
    @table_quiz_biblio ||= site.dbm_table('quiz_biblio', 'quiz')
  end
  def table_questions_biblio
    @table_questions_biblio ||= site.dbm_table(:quiz_biblio, 'questions')
  end

  # Définit toujours un quiz courant
  #
  # RETURN l'instance Quiz du questionnaire.
  #
  def mettre_quiz_courant_if_needed
    Quiz.get_current_quiz(forcer = true)
  end

  # Inverse de la méthode précédente, cette méthode supprime
  # le quiz courant pour qu'il n'y en ait plus. Noter que ça
  # fonctionne aussi s'il y a plusieurs quiz courants.
  def supprime_quiz_courant
    while q = Quiz.get_current_quiz
      opts = q.options.set_bit(0,0)
      q.set(options: opts)
      q.instance_variable_set('@options', opts)
    end
    Quiz.instance_variable_set('@current', nil)
    puts "Suppression du quiz par défaut nécessaire"
  end



  scenario "Contexte : aucune donnée et un quiz par défaut" do
    test 'Sans autres données, c’est le quiz par défaut qui s’affiche'
    quiz_id = mettre_quiz_courant_if_needed.id
    form_id = "form_quiz-#{quiz_id}"
    form_jid = "form#form_quiz-#{quiz_id}"
    visite_route 'quiz/show'
    la_page_a_pour_titre QUIZ_MAIN_TITRE
    la_page_a_le_formulaire form_id
    la_page_a_la_balise 'input', type: 'hidden', name: 'quiz[id]', in: form_jid, value: quiz_id.to_s
  end

  scenario 'Contexte : un bon suffixe mais un mauvais ID => le quiz courant' do
    test 'Avec un bon suffixe de base mais un mauvais ID, c’est le quiz courant qui est affiché.'
    q = mettre_quiz_courant_if_needed
    quiz_id = q.id
    form_id = "form_quiz-#{quiz_id}"
    form_jid = "form#form_quiz-#{quiz_id}"

    visite_route 'quiz/10000000/show?qdbr=biblio'
    la_page_a_pour_titre QUIZ_MAIN_TITRE
    la_page_a_le_formulaire form_id
    la_page_a_la_balise 'input', type: 'hidden', name: 'quiz[id]', in: form_jid, value: q.id.to_s,
      success: 'L’identifiant du quiz est bien celui du quiz courant'
    la_page_a_l_erreur 'Le quiz demandé n’existe pas. Quiz courant proposé.'
  end

  scenario 'Contexte : aucune donnée sans quiz par défaut' do
    test 'Sans donnée et sans quiz par défaut, c’est le dernier quiz fabriqué qui est affiché.'
    start_time = Time.now.to_i - 1
    Quiz.get_current_quiz == nil || supprime_quiz_courant
    last = Quiz.get_last_quiz
    last_quiz_id      = last.id
    last_quiz_suffix  = last.suffix_base.nil_if_empty
    expect(last.current?).to eq false
    success 'Le dernier quiz n’est pas marqué courant.'

    form_id = "form_quiz-#{last_quiz_id}"
    form_jid = "form#form_quiz-#{last_quiz_id}"

    visite_route 'quiz/show'
    la_page_a_pour_titre QUIZ_MAIN_TITRE
    la_page_a_le_formulaire form_id
    la_page_a_la_balise 'input', type: 'hidden', name: 'quiz[id]', in: form_jid, value: last.id.to_s,
      success: 'L’identifiant du quiz est bien celui du dernier quiz'
    la_page_napas_derreur
    # On reprend le dernier actualisé
    last = Quiz.new(last_quiz_id, last_quiz_suffix)
    expect(last.current?).to eq true
    success 'Le dernier quiz est maintenant marqué courant.'
    phil.a_recu_le_mail(
      subject: 'Quiz : forçage du quiz courant',
      sent_after:  start_time,
      message: ["##{last.id}", "#{last.suffix_base}", "#{last.titre}"],
      success: "Phil a reçu le mail l'avertissant du forçage de quiz courant."
    )
  end

  scenario 'Contexte : seulement le qdbr et un quiz par défaut' do
    test 'Avec seulement le qdbr, c’est le quiz par défaut qui est affiché'
    q = mettre_quiz_courant_if_needed
    form_id = "form_quiz-#{q.id}"
    form_jid = "form#form_quiz-#{q.id}"

    visite_route 'quiz/show?qdbr=biblio'
    la_page_a_pour_titre QUIZ_MAIN_TITRE
    la_page_a_pour_soustitre q.titre
    la_page_a_le_formulaire form_id
    la_page_a_la_balise 'input', type: 'hidden', name: 'quiz[id]', value: q.id.to_s, in: form_jid
  end

  scenario 'Contexte : seulement le suffixe de base et pas de quiz par défaut' do
    start_time = Time.now.to_i - 1
    test 'Sans quiz par défaut et seulement avec le suffixe de base, c’est le dernier fabriqué qui est affiché'
    Quiz.get_current_quiz == nil || supprime_quiz_courant
    last = q = Quiz.get_last_quiz
    last_id, last_suffix = [ last.id, last.suffix_base ]

    form_id = "form_quiz-#{q.id}"
    form_jid = "form#form_quiz-#{q.id}"

    visite_route 'quiz/show?qdbr=test'
    la_page_a_pour_titre QUIZ_MAIN_TITRE
    la_page_a_le_formulaire form_id
    la_page_a_la_balise 'input', type: 'hidden', name: 'quiz[id]', in: form_jid, value: last_id.to_s,
      success: 'L’identifiant du quiz est bien celui du dernier quiz'
    la_page_napas_derreur
    # On reprend le dernier actualisé
    last = Quiz.new(last_id, last_suffix)
    expect(last.current?).to eq true
    success 'Le dernier quiz est maintenant marqué courant.'
    phil.a_recu_le_mail(
      subject: 'Quiz : forçage du quiz courant',
      sent_after:  start_time,
      message: ["##{last_id}", "#{last.suffix_base}", "#{last.titre}"],
      success: "Phil a reçu le mail l'avertissant du forçage de quiz courant."
    )
  end

  scenario 'Contexte : toutes les données du courant et un simple inscrit' do
    test 'Avec les données du quiz courant et un simple inscrit, on affiche le quiz courant.'
    q = mettre_quiz_courant_if_needed
    form_id = "form_quiz-#{q.id}"
    form_jid = "form#form_quiz-#{q.id}"

    route = "quiz/#{q.id}/show?qdbr=#{q.suffix_base}"
    visite_route route
    la_page_a_pour_titre QUIZ_MAIN_TITRE
    la_page_a_pour_soustitre q.titre
    la_page_a_le_formulaire form_id
    la_page_a_la_balise 'input', type: 'hidden', name: 'quiz[id]', value: q.id.to_s, in: form_jid
  end

  scenario 'Contexte : toutes les données du courant et un abonné' do
    test 'Avec les données du quiz courant et un abonné, on affiche le quiz courant.'
    q = mettre_quiz_courant_if_needed
    form_id = "form_quiz-#{q.id}"
    form_jid = "form#form_quiz-#{q.id}"

    route = "quiz/#{q.id}/show?qdbr=#{q.suffix_base}"
    benoit.set_subscribed
    identify_benoit
    visite_route route
    la_page_a_pour_titre QUIZ_MAIN_TITRE
    la_page_a_pour_soustitre q.titre
    la_page_a_le_formulaire form_id
    la_page_a_la_balise 'input', type: 'hidden', name: 'quiz[id]', value: q.id.to_s, in: form_jid
  end

  scenario 'Contexte : toutes les données (autres que courant) et un simple inscrit' do
    test 'Avec des données autres que le quiz courant et un simple inscrit, c’est le quiz courant qui s’affiche, avec un message d’erreur.'
    q = mettre_quiz_courant_if_needed
    form_id = "form_quiz-#{q.id}"
    form_jid = "form#form_quiz-#{q.id}"
    # On doit trouver un autre quiz que le courant
    autreq = nil
    Quiz.allquiz.each do |qu|
      if qu.id != q.id
        autreq = qu; break
      end
    end
    autreq != nil || raise('On aurait dû trouver un autre quiz…')
    visite_route "quiz/#{autreq.id}/show?qdbr=#{autreq.suffix_base}"
    la_page_a_pour_titre QUIZ_MAIN_TITRE
    la_page_a_pour_soustitre q.titre
    la_page_a_le_formulaire form_id
    la_page_a_la_balise 'input', type: 'hidden', name: 'quiz[id]', value: q.id.to_s, in: form_jid
    la_page_a_l_erreur 'Seuls les abonnés peuvent exécuter le questionnaire demandé.'
    la_page_a_le_message 'Questionnaire courant affiché.'
  end

  scenario 'Contexte : toutes les données (autres que courant), un abonné' do
    test 'Avec les données d’un autre quiz que le courant et un abonné, le quiz voulu s’affiche.'

    # On fait de benoit un abonné
    benoit.set_subscribed

    # On doit trouver un quiz qui ne soit pas le quiz courant
    q = mettre_quiz_courant_if_needed

    # On doit trouver un autre quiz que le courant
    autreq = nil
    Quiz.allquiz.each do |qu|
      if qu.id != q.id
        autreq = qu; break
      end
    end
    autreq != nil || raise('On aurait dû trouver un autre quiz…')
    form_id = "form_quiz-#{autreq.id}"
    form_jid = "form#form_quiz-#{autreq.id}"

    # Hash avec en clé l'identifiant de la question et en valeur
    # l'instance Quiz::Question de la question
    dquestions = autreq.hquestions

    identify_benoit
    visite_route "quiz/#{autreq.id}/show?qdbr=#{autreq.suffix_base}"

    # === TEST ===
    la_page_a_pour_titre QUIZ_MAIN_TITRE
    la_page_a_pour_soustitre autreq.titre
    la_page_a_le_formulaire form_id
    la_page_a_la_balise 'input', type: 'hidden', name: 'quiz[id]', value: autreq.id.to_s, in: form_jid
    la_page_napas_derreur
  end

  scenario 'La page affiche les questions du quiz' do
    test 'La page affiche bien toutes les questions du quiz courant'

    q = mettre_quiz_courant_if_needed
    form_id = "form_quiz-#{q.id}"
    form_jid = "form#form_quiz-#{q.id}"

    visite_route 'quiz/show'
    puts "Un visiteur quelconque affiche le quiz courant (##{q.id}/#{q.suffix_base})."

    prefname = "q#{q.id}r"
    la_page_a_le_formulaire(form_id)
    la_page_a_la_balise('input', type: 'hidden', name: 'quiz[time]', in: form_jid)

    expect(page).to have_tag('form', with: {class: 'quiz'}) do

      q.hquestions.each do |qid, question|

        class_css_reponses = ['r']
        # Un DIV pour la question
        with_tag 'div', with: {class: 'question'}
        # Un DIV pour la question proprement dite
        question_str = question.question.formate_balises_propres.strip_tags
        with_tag 'div', with: {class: 'q', id: "q-#{qid}-question"}, text: /#{Regexp.escape question_str}/
        # Le UL contenant les réponses
        class_css_reponses << question.type[2]
        with_tag 'ul', with: {class: class_css_reponses.join(' ')}
        type_checkbox = question.type[1] == 'c'
        reponses = JSON.parse(question.reponses)
        expect(reponses).not_to be_empty
        reponses.to_sym.each_with_index do |dreponse, ireponse|
          if type_checkbox
            with_tag 'input', with: {type: 'checkbox', name: "#{prefname}[rep#{qid}_#{ireponse}]"}
          else # type radio
            with_tag 'input', with: {type: 'radio', name: "#{prefname}[rep#{qid}]", value: "#{ireponse}"}
          end
          with_tag 'label', text: /#{Regexp.escape dreponse[:lib]}/
        end
      end
      # /fin de boucle sur les questions
      success 'Le formulaire du quiz affiche correctement toutes les questions.'
    end
  end
end
