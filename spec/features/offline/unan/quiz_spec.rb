# encoding: UTF-8
=begin

  Test du questionnaire
  ---------------------
  On va tester l'enregistrement d'un premier questionnaire d'un auteur
  suivant le programme.

=end
TITRE_PAGE_UNAN = 'UN FILM/ROMAN EN UN AN'
feature "Enregistrement d'un questionnaire du programme UNAN" do
  scenario "Benoit trouve le questionnaire (non démarré) de son deuxième jour" do
    test 'Benoit trouve le questionnaire de son deuxième jour'
    reset_auteur_unan benoit
    benoit.set_pday_to 2
    nombre_works_init = benoit.table_works.count
    identify_benoit
    visite_route 'bureau/home?in=unan'
    la_page_a_pour_titre TITRE_PAGE_UNAN
    la_page_a_le_lien 'Quiz (1)'
    click_link 'Quiz (1)'
    shot 'after-benoit-click-onglet-quiz'
    la_page_a_la_balise 'h3', text: "Quiz"
    la_page_napas_le_formulaire 'form_quiz_2'
    la_page_a_la_balise 'section#works_unstarted div#work-quiz-14'
    within('section#works_unstarted div#work-quiz-14') do
      click_link "Démarrer ce questionnaire"
    end
    success "Benoit a démarré son premier questionnaire"
    la_page_a_le_formulaire 'form_quiz_2'
    success 'Le questionnaire est affiché'
    expect(benoit.table_works.count).to eq nombre_works_init + 1
    success 'Un nouveau work a été créé pour Benoit'
  end
  scenario 'Benoit peut démarrer, remplir et soumettre le quiz de son deuxième jour' do
    test 'Benoit remplit et soumet avec succès le questionnaire de son deuxième jour'
    reset_auteur_unan benoit
    benoit.set_pday_to 2
    expect(benoit.table_quiz.count).to eq 0
    identify_benoit
    visite_route 'bureau/home?in=unan'
    la_page_a_pour_titre TITRE_PAGE_UNAN
    click_link 'Quiz (1)'
    success 'Benoit affiche l’onglet “Quiz”'
    within('section#works_unstarted div#work-quiz-14') do
      click_link "Démarrer ce questionnaire"
    end
    success 'Benoit démarre le premier questionnaire'
    la_page_a_le_formulaire 'form_quiz_2'
    success 'Le premier questionnaire est affiché.'
    expect(benoit.table_quiz.count).to eq 0
    success "Le premier quiz n'a pas encore été enregistré."
    data_form = {
      'quiz-2_q_4_r_1'  => {type: :radio},
      'quiz-2_q_5_r_2'  => {type: :radio},
      'quiz-2_q_6_r_2'  => {type: :radio},
      'quiz-2_q_7_r_5'  => {type: :checkbox, value: true},
      'quiz-2_q_7_r_3'  => {type: :checkbox, value: true},
      'quiz-2_q_8_r_1'  => {type: :radio},
      'quiz-2_q_9_r_1'  => {type: :radio},
      'quiz-2_q_10_r_2' => {type: :radio},
      'quiz-2_q_11_r_2' => {type: :radio},
      'quiz-2_q_12_r_3' => {type: :radio}
    }
    benoit.remplit_le_formulaire(page.find('form#form_quiz_2')).
      avec(data_form).
      et_le_soumet('Soumettre le questionnaire')
    success 'Benoit a rempli le questionnaire et l’a soumis avec succès.'
    la_page_napas_derreur
    la_page_affiche 'Merci pour vos réponses.'
    la_page_a_le_message 'Votre questionnaire a été évalué et enregistré avec succès.'
    la_page_a_la_balise 'div', class: 'resultat_quiz'
    expect(benoit.table_quiz.count).to eq 1
    hquiz = benoit.table_quiz.select.first
    expect(hquiz[:reponses]).not_to eq nil
    hreponses = JSON.parse(hquiz[:reponses])
    expect(hreponses).to be_instance_of Hash
    success "Le premier quiz a reçu les réponses."

    # On vérifie que les réponses données soient bien réaffichées
    data_form.each do |fid, fdata|
      case fdata[:type]
      when :radio
        expect(page.find("input##{fid}[type=\"radio\"]")).to be_checked
      when :checkbox
        expect(page.find("input##{fid}[type=\"checkbox\"]")).to be_checked
      end
    end
    success 'Le questionnaire réaffiche les réponses de Benoit.'
  end
end
