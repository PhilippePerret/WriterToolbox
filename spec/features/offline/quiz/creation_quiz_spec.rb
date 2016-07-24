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
    visite_route 'quiz/new'
    expect(page).not_to have_tag('h1', text: 'Quizzzz !')
    expect(page).not_to have_tag('h2', text: 'Nouveau quiz')
  end

  scenario 'Un administrateur peut rejoindre la section de création d’un quiz' do
    identify_phil
    visite_route 'quiz/new'
    expect(page).to have_tag('h1', text: 'Quizzzz !')
    expect(page).to have_tag('h2', text: 'Nouveau quiz')
  end

  scenario 'Un administrateur peut créer un nouveau quiz' do
    identify_phil
    visite_route 'quiz/new'
    expect(page).to have_link "Nouveau quiz dans la base “Biblio”"
    click_link "Nouveau quiz dans la base “Biblio”"
    expect(page).to have_tag('form', with: {id: 'edition_quiz', action: 'quiz//edit'}) do
      with_tag('input', with: {type: 'hidden', name: 'qdbr', value: 'biblio'})
    end
    # On remplit le formulaire avec les données minimales
    within('form#edition_quiz') do
      fill_in 'quiz_titre', with: "Nouveau quiz"
      fill_in 'quiz_groupe', with: 'scenodico'
      click_button 'Enregistrer'
    end
    expect(page).to have_tag('form#edition_quiz')
    quiz_id = page.find('form#edition_quiz input#quiz_id', visible: false).value
    quiz_id = quiz_id.to_i

    # Pour le détruire à la fin
    $quiz2destroy << {id: quiz_id, suffix_base: 'biblio'}

    # Le message de confirmation de création
    expect(page).to have_notice("Quiz ##{quiz_id} créé avec succès.")
    # L'action a été correctement réglée
    expect(page).to have_tag('form#edition_quiz', with: {action: "quiz/#{quiz_id}/edit"})

    # Pas encore de questions à ce quiz
    qids = page.find('form#edition_quiz input#quiz_questions_ids').value
    expect(qids).to eq ''

    # On crée une première question
    expect(page).to have_link "Nouvelle question"
    click_link 'Nouvelle question'
    expect(page).not_to have_css('form#edition_quiz')
    expect(page).to have_css('form#edition_question_quiz')

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

    # Le formulaire quiz est affiché
    expect(page).to have_css('form#edition_quiz')
    # Le formulaire question est masqué
    expect(page).not_to have_css('form#edition_question_quiz')

    # La question a été enregistrée
    table_questions = site.dbm_table("quiz_biblio", 'questions')
    dquestion = table_questions.select(where: "question = '#{titre_question}'").first
    qid = dquestion[:id]

    # La question a été mise dans le champ
    qids = page.find('form#edition_quiz input#quiz_questions_ids').value
    expect(qids).not_to eq ''
    expect(qids).to eq "#{qid}"

    # La question est déjà enregistrée dans la donnée du qui
    table_quiz = site.dbm_table("quiz_biblio", 'quiz')
    dquiz = table_quiz.get(quiz_id)
    expect(dquiz[:questions_ids]).to eq "#{qid}"

  end
end
