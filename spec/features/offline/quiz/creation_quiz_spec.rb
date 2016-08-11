feature "Création d'un quiz" do

  before(:all) do
    # Pour mettre les informations sur les quiz à détruire
    # C'est une liste de hash contenant {:id, :suffix_base}
    $quiz2destroy = Array.new
  end

  after(:all) do
    unless $quiz2destroy.empty?
      $quiz2destroy.each do |dquiz|
        quiz_id = dquiz[:id]
        sufbase = dquiz[:suffix_base]
        table_quiz = site.dbm_table("quiz_#{sufbase}", 'quiz')
        table_questions = site.dbm_table("quiz_#{sufbase}", 'questions')
        qids = table_quiz.get(quiz_id)[:questions_ids].nil_if_empty
        # Détruire le quiz
        table_quiz.delete(quiz_id)
        puts "Quiz ##{quiz_id} détruit."
        # Détruire les questions
        unless qids.nil?
          qids = qids.split(' ').join(', ')
          table_questions.delete(where: "id IN (#{qids})")
          puts "Questions #{qids} détruites."
        end
      end
    end
  end

  scenario "Un non administrateur ne peut pas rejoindre la section de création d'un quiz" do
    test 'Un non administrateur ne peut pas rejoindre la section de création de quiz'
    visite_route 'quiz/new'
    la_page_napas_pour_titre 'Quizzzz !'
    la_page_napas_pour_soustitre 'Nouveau quiz'
  end

  scenario 'Un administrateur peut rejoindre la section de création d’un quiz' do
    test 'Un administrateur peut rejoindre la section de création d’un quiz'
    identify_phil
    visite_route 'quiz/new'
    la_page_a_pour_titre 'Quizzzz !'
    la_page_a_pour_soustitre 'Nouveau quiz'
  end

  scenario 'Un administrateur peut créer un nouveau quiz' do
    test 'Un administrateur peut créer un nouveau quiz et une question'
    identify_phil
    visite_route 'quiz/new'
    la_page_a_le_lien 'Nouveau quiz dans la base “Test”'
    click_link "Nouveau quiz dans la base “Test”"
    la_page_a_le_formulaire 'edition_quiz', action: 'quiz//edit'
    la_page_a_la_balise 'input', type: 'hidden', name: 'qdbr', value: 'test', in: 'form#edition_quiz'

    data_form = {
      'quiz_titre'  => {value: 'Nouveau quiz'},
      'quiz_groupe' => {value: 'test'}
    }
    phil.remplit_le_formulaire(page.find('form#edition_quiz')).
      avec(data_form).
      et_le_soumet('Enregistrer')

    la_page_a_le_formulaire 'edition_quiz',
      success: 'Le formulaire d’édition est réaffiché.'

    quiz_id = page.find('form#edition_quiz input#quiz_id', visible: false).value
    quiz_id = quiz_id.to_i
    puts "L'ID du nouveau questionnaire est #{quiz_id}."

    # Pour le détruire à la fin
    $quiz2destroy << {id: quiz_id, suffix_base: 'test'}

    la_page_a_le_message "Quiz ##{quiz_id} créé avec succès."
    la_page_a_la_balise 'form', id: 'edition_quiz', action: "quiz/#{quiz_id}/edit",
      success: "Le formulaire a la bonne action pour réenregistrer le quiz."

    # Pas encore de questions à ce quiz
    qids = page.find('form#edition_quiz input#quiz_questions_ids').value
    expect(qids).to eq ''
    success "La formulaire n'a pas encore de questions."

    # On crée une première question
    la_page_a_le_lien 'Nouvelle question', in: 'form#edition_quiz'
    click_link 'Nouvelle question'
    la_page_a_le_formulaire 'edition_question_quiz'

    titre_question = "Une nouvelle question à #{Time.now} ?"
    within('form#edition_question_quiz') do
      # Pour créer 3 nouvelles réponses
      fill_in('question_question', with: titre_question)
      click_link '+ réponse'
      expect(page).to have_tag('input', with: {id: 'question_reponse_1_libelle'})
      fill_in('question_reponse_1_libelle', with: "Première réponse")
      fill_in('question_reponse_1_points', with: '0')
      click_link '+ réponse'
      expect(page).to have_tag('input', with: {id: 'question_reponse_2_libelle'})
      fill_in('question_reponse_2_libelle', with: "Deuxième réponse")
      fill_in('question_reponse_2_points', with: '0')
      click_link '+ réponse'
      expect(page).to have_tag('input', with: {id: 'question_reponse_3_libelle'})
      fill_in('question_reponse_3_libelle', with: "Troisième réponse")
      fill_in('question_reponse_3_points', with: '10')
      fill_in('question_raison', with: "Ceci est la raison de la bonne réponse, la troisième.")
      click_button 'Enregistrer la question'
    end

    la_page_a_la_balise 'form#edition_question_quiz',
      visible: false,
      success: "Le formulaire pour les questions est masqué."

    # La question a été enregistrée
    table_questions = site.dbm_table("quiz_test", 'questions')
    dquestion = table_questions.select(where: "question = '#{titre_question}'").first
    qid = dquestion[:id]

    # La question a été mise dans le champ
    qids = page.find('form#edition_quiz input#quiz_questions_ids').value
    expect(qids).not_to eq ''
    expect(qids).to eq "#{qid}"
    success "La question ##{qid} a été enregistrée."

    # La question est déjà enregistrée dans la donnée du quiz
    table_quiz = site.dbm_table("quiz_test", 'quiz')
    dquiz = table_quiz.get(quiz_id)
    expect(dquiz[:questions_ids]).to eq "#{qid}"
    success "La question a été ajouté aux questions du quiz courant."

  end
end
