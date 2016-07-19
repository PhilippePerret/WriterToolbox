
feature "Test de la base d'administration du quiz du scénodico" do
  before(:all) do
    puts "-> Je conserve les valeurs actuelles du quiz"
  end

  after(:all) do
    puts "-> Je remets les valeurs du quiz"
  end

  let(:home_scenodico) { "#{site.local_url}/scenodico/home" }
  scenario "Un administrateur trouver le lien pour éditer le quiz" do


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

    identify_phil
    visit home_scenodico
    click_link '[Edit Quiz]'

    expect(page).to have_tag('form', with: {id: 'edition_quiz'})

    puts "J'ai fini de modifier les valeurs du quiz"
  end
end
