=begin

Module de test d'une nouvelle question

=end
feature "Création d'une nouvelle question" do

  def table_questions
    @table_questions ||= site.dbm_table('quiz_biblio', 'questions')
  end

  scenario "L'administrateur trouve un lien sur le formulaire du quiz pour créer une nouvelle question" do
    identify_phil
    visit_route 'scenodico/quiz_edit'
    expect(page).to have_link('Nouvelle question')
    expect(page).not_to have_css('form#edition_question_quiz')
    # C'est un lien qui ouvre simplement le formulaire des questions
    # sous le formulaire du questionnaire.
    click_link 'Nouvelle question'
    expect(page).to have_css('form#edition_question_quiz')
    expect(page).not_to have_css('form#edition_quiz')
    expect(page).to have_tag('form', with: {id: 'edition_question_quiz'}) do
      with_tag 'input', with: {id: 'question_question', name: 'question[question]'}
      # Il n'y a PAS encore de réponse
      without_tag 'input', with: {id: 'question_reponse_1_libelle', name: 'question[reponse_1][libelle]'}
      # Il y a un menu pour le type
      with_tag 'select', with: {id: 'question_type_f', name: 'question[type_f]'}
      with_tag 'select', with: {id: 'question_type_c', name: 'question[type_c]'}
      with_tag 'select', with: {id: 'question_type_a', name: 'question[type_a]'}
      # Champ pour l'indication
      with_tag 'textarea', with: {id: 'question_indication', name: 'question[indication]'}
      with_tag 'textarea', with: {id: 'question_raison', name: 'question[raison]'}
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
      type_f: '0', # type de question, une seule valeur pour le
      type_c: 'r', # pour "radio"
      type_a: 'c', # pour l'alignement
      options:      "0rc" # r ou c pour le 2e, c, l, ou m pour le 3e
    }
    within('form#edition_question_quiz') do
      fill_in('question[question]',   with: qdata[:question])
      fill_in('question[indication]', with: qdata[:indication])
      fill_in('question[raison]',     with: qdata[:raison])
      select(qdata[:type_c], from: 'question_type_c')
      select(qdata[:type_a], from: 'question_type_a')
      select(qdata[:type_f], from: 'question_type_f')
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
    puts "Données enregistrées : #{dq.inspect}"
    expect(dq[:question]).to eq qdata[:question]
    expect(dq[:raison]).to eq qdata[:raison]
    expect(dq[:indication]).to eq nil
    expect(dq[:options]).to eq qdata[:options]
  end
end
