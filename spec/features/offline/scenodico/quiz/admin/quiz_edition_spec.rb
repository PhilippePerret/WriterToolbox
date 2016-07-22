
feature "Test de la base d'administration du quiz du scénodico" do

  def table_quiz
    @table_quiz ||= begin
      if SiteHtml::DBM_TABLE.database_exist?('boite-a-outils_quiz_biblio')
        site.dbm_table('quiz_biblio', 'quiz', online = false)
      end
    end
  end
  def table_questions
    @table_questions ||= site.dbm_table('quiz_biblio', 'questions', online = false)
  end

  before(:all) do
    if table_quiz
      @quiz_data_init = table_quiz.get(1)
      puts "-> Je conserve les valeurs actuelles du quiz (#{@quiz_data_init.inspect})"
    else
      puts "Pas de table des quiz scénodico, pas de données à conserver"
    end
  end

  after(:each) do
    if @quiz_data_init.nil?
      puts "-> Les valeurs du quiz ne sont pas encore définies"
    else
      puts "-> Je remets les valeurs initiales du quiz (#{@quiz_data_init.inspect})"
    end
  end

  let(:home_scenodico) { "#{site.local_url}/scenodico/home" }
  scenario "Un administrateur trouve le lien pour éditer le quiz" do


    visit home_scenodico

    expect(page).to have_tag('h1', text: 'Le Scénodico')
    expect(page).to have_link('Quiz')
    # Il ne doit pas y avoir de bouton pour éditer le quiz
    expect(page).not_to have_link('[Edit Quiz]')

    identify_phil

    visit home_scenodico

    expect(page).to have_tag('h1', text: 'Le Scénodico')
    expect(page).to have_link('Quiz')
    # Cette fois, le lien pour éditer le quiz existe
    expect(page).to have_link('[Edit Quiz]')

  end

  scenario 'Un administrateur peut atteindre le formulaire du quiz' do
    identify_phil
    visit home_scenodico
    click_link '[Edit Quiz]'

    expect(page).to have_css('h1', text: 'Le Scénodico')
    expect(page).to have_css('h2', text: 'Édition du quiz')
    expect(page).to have_css('form#edition_quiz')
  end

  scenario 'Le formulaire des données du quiz est correct' do

    # Noter que ça sert aussi à évaluer le module 'quiz' puisque
    # ces champs doivent être communs à tous les quiz

    site.require_module 'quiz'

    identify_phil
    visit home_scenodico
    click_link '[Edit Quiz]'


    expect(page).to have_css( 'form#edition_quiz input[type="hidden"][name="quiz[id]"]#quiz_id', visible: false)

    expect(page).to have_tag('form', with: {id: 'edition_quiz'}) do

      # Le titre qui quiz existe
      with_tag 'input', with: {type:'text', id: 'quiz_titre', name: 'quiz[titre]'}

      # L'IDentifiant, affiché sous forme de texte
      with_tag 'span', with: {id: "quizid"}, text: "ID du quiz : 1"

      # Le groupe auquel appartient le quiz
      with_tag 'input', with: {type: 'text', id: 'quiz_groupe', name: 'quiz[groupe]'}

      # Le type de questionnaire
      with_tag 'select', with: {id: 'quiz_type', name: 'quiz[type]'} do
        ::Quiz::TYPES.each do |tid, tdata|
          with_tag 'option', with: {value: tdata[:value]}, text: tdata[:hname]
        end
      end
      # Pour un quiz avec question dans un ordre aléatoire
      with_tag 'input', with: {type:'checkbox', id: 'quiz_random', name: 'quiz[random]'}
      # Pour un quiz qui définit le nombre de questions maximum (fonctionne
      # forcément avec un quiz aléatoire)
      with_tag 'input', with: {type:'text', id: 'quiz_max_questions', name: 'quiz[max_questions]'}

      # Bien entendu, un champ pour les questions ordonnées
      with_tag 'input', with: {type: 'text', id: 'quiz_questions_ids', name: 'quiz[questions_ids]'}

      # Pour décrire le quiz pour l'utilisateur
      with_tag 'textarea', with: {id: 'quiz_description', name: 'quiz[description]'}

      # Un bouton pour soumettre le questionnaire
      with_tag 'input', with: {type: 'submit', value: "Enregistrer"}

    end

  end

  scenario 'le formulaire permet de modifier le questionnaire' do
    # Noter que ça sert aussi à évaluer le module 'quiz' puisque
    # ces champs doivent être communs à tous les quiz

    site.require_module 'quiz'

    new_titre = "Quiz scénodico du #{Time.now}"
    new_liste_questions = '10 9 8 7 6 5'

    dquiz = table_quiz.get(1)
    expect(dquiz[:titre]).not_to eq new_titre
    expect(dquiz[:question_ids]).not_to eq new_liste_questions



    identify_phil
    visit home_scenodico
    click_link '[Edit Quiz]'

    expect(page).to have_tag('form', with: {id: 'edition_quiz'})

    within('form#edition_quiz') do
      fill_in('quiz_titre', with: new_titre)
      fill_in('quiz_questions_ids', with: new_liste_questions)
      click_button("Enregistrer")
    end
    shot 'after-submit-form'

    # Le nouveau titre a été enregistré
    dquiz = table_quiz.get(1)
    expect(dquiz[:titre]).to eq new_titre
    expect(dquiz[:questions_ids]).to eq new_liste_questions
  end

  scenario 'Le formulaire contient la liste éditable des questions' do
    site.require_module 'quiz'

    dquiz = table_quiz.get(1)

    qids = (dquiz[:questions_ids] || '').split(' ')
    expect(qids).not_to be_empty

    dquestions = table_questions.select(where: "id IN (#{qids.join(', ')})")

    expect(dquestions).not_to be_empty
    identify_phil
    visit home_scenodico
    click_link '[Edit Quiz]'

    # Toutes les questions doivent être affichées par leur
    # titre (la question)
    dquestions.each do |dquestion|
      within('form#edition_quiz') do
        expect(page).to have_tag('li', with: {'data-qid' => dquestion[:id].to_s}) do
          with_tag('span', text: /#{Regexp::escape dquestion[:question]}/)
          with_tag( 'a', with: {class: 'tiny', onclick: 'QuizQuestion.edit(this)', 'data-qid' => dquestion[:id].to_s, 'data-quiz' => 'quiz_biblio'}, text: 'edit')
          with_tag('a', with: {class: 'tiny'}, text: 'sup')
        end

      end
    end


  end

  scenario 'On peut éditer une question depuis la liste des questions' do
    site.require_module 'quiz'
    dquiz = table_quiz.get(1)
    # Les questions
    qids = (dquiz[:questions_ids] || '').split(' ')
    expect(qids).not_to be_empty
    dquestions = table_questions.select(where: "id IN (#{qids.join(', ')})")
    expect(dquestions).not_to be_empty

    identify_phil
    visit home_scenodico
    click_link '[Edit Quiz]'

    expect(page).to have_css('form#edition_quiz')
    expect(page).not_to have_css('form#edition_question_quiz')

    # === Test ===
    dquestion = dquestions.first
    within("form#edition_quiz li#li-q-#{dquestion[:id]}") do
      click_link('edit')
    end

    # La question est passée en édition
    expect(page).not_to have_css('form#edition_quiz')
    expect(page).to have_css('form#edition_question_quiz')

    expect(page).to have_tag('form', with:{id: 'edition_question_quiz'}) do
      with_tag('input', with: {id: 'question_question', value: dquestion[:question] })
    end
  end
end