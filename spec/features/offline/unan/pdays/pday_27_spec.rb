# encoding: UTF-8
=begin

  Test du 27 jour-programme de Benoit
  -----------------------------------
  Ce jour-programme présente le premier exemple de questionnaire réutilisable,
  un questionnaire pour tester la valeur de différents projets examinés

=end
feature "27e jour-programme, le test réutilisable" do
  before(:all) do
    reset_auteur_unan benoit
    benoit.set_pday_to(27, {
      # On marque achevés les travaux jusqu'au 26e jour-programme
      complete_upto: 26
      })
  end
  scenario "Benoit peut utiliser le test réutilisable pour estimer son travail" do
    test 'Benoit utilise le test reusable pour tester ses projets en examen'
    start_time = NOW - 1

    # Nombre de points de Benoit au départ
    nombre_points_init = benoit.points.freeze

    expect(benoit.program.current_pday).to eq 27
    success 'Benoit a bien été passé au jour programme 27'
    identify_benoit
    la_page_a_pour_soustitre UNAN_SOUS_TITRE_BUREAU
    benoit.clique_le_lien('Quiz (1)')
    la_page_a_la_balise('h3', text: 'Quiz')
    la_page_a_la_balise('div', id: 'work-24')
    la_page_a_le_lien('Répondre à ce questionnaire', in: 'div#work-24')
    la_page_a_la_balise('div', class: 'titre', text: 'Évaluation des projets', in: 'div#work-24')
    benoit.clique_le_lien('Répondre à ce questionnaire', in: 'div#work-24')

    la_page_a_le_soustitre UNAN_SOUS_TITRE_BUREAU
    la_page_a_le_formulaire('form_quiz-9')

    # === TEST : Benoit remplit une première fois le questionnaire ===
    # Note : on choisit des questions au hasard et on les coche
    #
    reponses = benoit.remplit_le_formulaire('form_quiz-9').
      au_hasard.
      et_clique('Soumettre').
      resultat

    # === VÉRIFICATION ===
    la_page_a_le_soustitre UNAN_SOUS_TITRE_BUREAU
    la_page_a_la_balise('div', id: 'div_note_finale')
    la_page_affiche('Aucun point n’est enregistré pour ce questionnaire. Vous pouvez le réutiliser pendant 2 jours.')
    la_page_a_la_balise('a', text: "Recommencer", in: 'form#form_quiz-9',
      success: 'Le formulaire a un bouton “Recommencer” pour ré-essayer le formulaire.')

    ben = User.new(benoit.id) # pour être sûr
    expect(ben.points).to eq nombre_points_init
    success 'Benoit a toujours le même nombre de points.'

    # === TEST ON DOIT POUVOIR LE RÉUTILISER UNE AUTRE FOIS ===
    la_page_a_le_formulaire('form_quiz-9')
    within('form#form_quiz-9'){click_link 'Recommencer'}
    la_page_a_le_soustitre UNAN_SOUS_TITRE_BUREAU
    la_page_napas_la_balise('div', id: 'div_note_finale')

    # === TEST : Benoit remplit une première fois le questionnaire ===
    # Note : on choisit des questions au hasard et on les coche
    #
    reponses = benoit.remplit_le_formulaire('form_quiz-9').
      au_hasard.
      et_le_soumet('Soumettre').
      resultat

    # puts "Réponses : #{reponses.inspect}"
    la_page_a_le_soustitre UNAN_SOUS_TITRE_BUREAU
    la_page_a_la_balise('div', id: 'div_note_finale')

    ben = User.new(benoit.id) # pour être sûr
    expect(ben.points).to eq nombre_points_init
    success 'Benoit a toujours le même nombre de points.'

    # === TEST ON DOIT POUVOIR LE RÉUTILISER UNE AUTRE FOIS ENCORE ===
    la_page_a_le_formulaire('form_quiz-9')
    within('form#form_quiz-9'){click_link 'Recommencer'}
    la_page_a_le_soustitre UNAN_SOUS_TITRE_BUREAU
    la_page_napas_la_balise('div', id: 'div_note_finale')
    la_page_a_le_formulaire('form_quiz-9')


  end
end
