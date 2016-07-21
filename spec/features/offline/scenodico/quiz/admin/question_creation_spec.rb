=begin

Module de test d'une nouvelle question

Ce test permet de savoir si on peut créer une nouvelle question.
Il se sert du questionnaire 1 de la table 'quiz_biblio' qui concerne
le scénodico (questionnaire facile).

=end
feature "Création d'une nouvelle question" do

  def table_questions
    @table_questions ||= site.dbm_table('quiz_biblio', 'questions')
  end
  def table_quiz
    @table_quiz ||= site.dbm_table('quiz_biblio', 'quiz')
  end

  before(:all) do
    # Pour récupérer les questions créées
    $questions2destroy = Array.new
  end
  after(:all) do
    # Si des questions ont été créées, il faut les détruire
    if $questions2destroy.count > 0
      table_questions.delete(where: "id IN (#{$questions2destroy.join(', ')})")
    end
  end

  scenario "L'administrateur trouve un lien sur le formulaire du quiz pour créer une nouvelle question" do
    identify_phil
    visit_route 'scenodico/quiz_edit'
    expect(page).to have_link('Nouvelle question')
    expect(page).not_to have_css('form#edition_question_quiz')
    # C'est un lien qui ouvre simplement le formulaire des questions
    # sous le formulaire du questionnaire.
    click_link 'Nouvelle question'
    sleep 1
    expect(page).to have_css('form#edition_question_quiz')
    expect(page).not_to have_css('form#edition_quiz')

    expect(page).to have_tag('form', with: {id: 'edition_question_quiz'}) do
      with_tag 'input', with: {id: 'question_question', name: 'question[question]'}
      with_tag 'select', with: {id: 'question_type_f', name: 'question[type_f]'}
      with_tag 'select', with: {id: 'question_type_a', name: 'question[type_a]'}
      with_tag 'select', with: {id: 'question_type_c', name: 'question[type_c]'}
      with_tag 'textarea', with: {id: 'question_indication', name: 'question[indication]'}
      with_tag 'textarea', with: {id: 'question_raison', name: 'question[raison]'}
      # Je ne sais pas pourquoi, mais il faut mettre les without_tag après,
      # sinon ça merde sur les autres conditions, comme s'il n'y avait plus
      # de contexte.
      without_tag( 'input', with: {id: 'question_reponse_1_libelle', name: 'question[reponse_1][libelle]'} )
    end

  end

  scenario 'L’administrateur peut créer une nouvelle question' do

    nombre_questions_init = table_questions.count

    identify_phil
    visit_route 'scenodico/quiz_edit'
    click_link 'Nouvelle question'
    expect(page).to have_css('form#edition_question_quiz')

    qdata = {
      question: "La question du #{Time.now}",
      reponses: [
        {libelle: "Réponse 1 de question #{NOW}", points: '10'},
        {libelle: "Réponse 2 de question #{NOW}", points: ''},
        {libelle: "Réponse 3 de question #{NOW}", points: '20'},
        {libelle: "Réponse 4 de question #{NOW}", points: '  '}
      ],
      indication:   "", # ne rien mettre
      raison:       "La raison du choix de la réponse 3.",
      type_f: 'Indifférent', # type de question, une seule valeur pour le
      type_c: 'Un seul choix (radio)', #'r', # pour "radio"
      type_a: 'L\'un en dessous de l\'autre', # pour l'alignement
      type:   "0rv" # donnée enregistrée
    }

    expect(page).to have_css('form#edition_question_quiz select#question_type_c')

    within('form#edition_question_quiz') do
      fill_in('question[question]',   with: qdata[:question])
      fill_in('question[indication]', with: qdata[:indication])
      fill_in('question[raison]',     with: qdata[:raison])
      select(qdata[:type_c], from: 'question[type_c]')
      select(qdata[:type_a], from: 'question[type_a]')
      select(qdata[:type_f], from: 'question[type_f]')
    end

    # Le bouton pour ajouter une réponse
    expect(page).to have_link('+ réponse')

    qdata[:reponses].each_with_index do |dreponse, irep|
      irealrep = irep + 1
      fid_libelle = "question_reponse_#{irealrep}_libelle"
      fid_points  = "question_reponse_#{irealrep}_points"
      expect(page).not_to have_tag("form#edition_question_quiz input##{fid_libelle}")
      expect(page).not_to have_tag("form#edition_question_quiz input##{fid_points}")
      # On ajoute un champ de réponse
      click_link('+ réponse')
      expect(page).to have_tag("form#edition_question_quiz input##{fid_libelle}")
      expect(page).to have_tag("form#edition_question_quiz input##{fid_points}")
      within('form#edition_question_quiz') do
        fill_in(fid_libelle, with: dreponse[:libelle])
        fill_in(fid_points, with: dreponse[:points])
      end
    end # fin de boucle sur les réponses

    # Le formulaire doit avoir un bouton pour enregistrer la
    # question
    expect(page).to have_tag('form#edition_question_quiz input', with: {type:'submit', value: "Enregistrer la question"})
    # On enregistre la question
    within('form#edition_question_quiz') do
      click_button 'Enregistrer la question'
    end

    # Il doit y avoir une nouvelle question
    expect(table_questions.count).to eq nombre_questions_init + 1
    # On récupère la dernière question
    dq = table_questions.select(limit: 1, order: 'id DESC').first
    qid = dq[:id]
    # Pour que la question soit détruite à la fin.
    $questions2destroy << qid
    expect(dq[:question]).to eq qdata[:question]
    expect(dq[:raison]).to eq qdata[:raison]
    expect(dq[:indication]).to eq nil
    expect(dq[:type]).to eq qdata[:type]


    # Il faut tester que la question est bien ajoutée aux
    # questions du quiz. Si c'est le cas, on actualise tout
    # de suite la liste des questions.
    dquiz = table_quiz.get(1)
    qids = (dquiz[:questions_ids] || '').split(' ')
    expect(qids).to include qid.to_s
    thelast = qids.last.to_i

    # Si c'est bien le cas, on retire cet identifiant pour
    # ne pas modifier le questionnaire.
    qids.pop
    table_quiz.update(1, questions_ids: qids.join(' '))

    # Ça doit bien être le dernier
    expect(thelast).to eq qid


  end
end
