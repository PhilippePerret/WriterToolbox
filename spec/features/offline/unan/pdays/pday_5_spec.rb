=begin

  Test du Jour-programme 5 pour Benoit
  Ce jour-programme utilise un Quiz et permet donc de savoir si les quiz
  fonctionnent bien.
  Pour trouver un quiz qui ne doit pas être enregistré, voir le PDay 27 qui
  utilise le quiz sur la valeur des projets.

=end
feature "Jour-programme 5" do
  before(:all) do
    reset_auteur_unan benoit
    benoit.set_pday_to 5
  end
  scenario "Au PDay 5, Benoit trouve un quiz qu'il peut remplir et soumettre" do
    test "Benoit trouve un quiz, l'affiche, le remplit et le soumet avec succès"

    start_time = NOW - 1

    table_resultats = site.dbm_table(:quiz_unan, 'resultats')
    table_resultats.delete(where: {user_id: benoit.id})
    nombre_resultats_init = table_resultats.count
    puts "Nombre de résultats au quiz au départ : #{nombre_resultats_init}"

    expect(benoit.table_works.count).to eq 0
    success 'Benoit n’a pas encore de works'
    expect(benoit.program.points).to eq 0
    success 'Benoit n’a pas encore de points pour son programme'

    identify_benoit
    la_page_a_le_soustitre UNAN_SOUS_TITRE_BUREAU
    benoit.clique_le_lien('Quiz (2)')
    shot 'pday5-onglet-quiz-benoit'
    la_page_a_la_balise('h3', text: 'Quiz')
    la_page_a_la_balise('h4', text: 'Quiz à remplir')
    la_page_a_la_balise('div', id: 'work-25', in: 'section#works_unstarted',
      success: 'La section des travaux à démarrer contient le travail #24 correspondant au quiz #9.')
    la_page_affiche('Répondre à ce questionnaire', in: 'div#work-25',
      success: 'La section contient un bouton pour marquer ce questionnaire vu (et le démarrer).')
    benoit.clique_le_lien('Répondre à ce questionnaire', in: 'div#work-25')
    # sleep 10


    # === TEST ===
    # Le questionnaire doit être bien affiché
    la_page_a_la_balise('h5', text: 'Les Fondamentales', in: 'section#current_works')
    la_page_a_le_formulaire('form_quiz-8', action: 'quiz/8/show')

    expect(benoit.table_works.count).to eq 1
    hw = benoit.table_works.select.first
    expect(hw[:abs_work_id]).to eq 25
    expect(hw[:abs_pday]).to eq 5
    success 'Benoit a un premier work qui a pour abs_work_id 25 et pour abs_pday 5'
    expect(hw[:points]).to eq 0
    success 'Le work de Benoit n’a pas encore de points'

    # === Benoit ne remplit pas le formulaire et le soumet ===
    # Cela doit produire une erreur
    benoit.remplit_le_formulaire('form_quiz-8').
      et_le_soumet('Soumettre')
    la_page_a_le_soustitre UNAN_SOUS_TITRE_BUREAU
    shot 'benoit-soumet-quiz-sans-repondre'
    la_page_napas_la_balise('div', id: 'div_note_finale')
    la_page_a_l_erreur('Il faut remplir le quiz, pour obtenir une évaluation')

    # === Benoit remplit le formulaire et le soumet ===
    # Ça pose beaucoup de problème apparemment de cocher des radios
    # boutons, il faut les essayer plusieurs fois avant d'y arriver
    # Note : peut-être est-ce que ça tient au fait qu'ils ne sont pas
    # dans l'ordre du questionnaire
    # En tout cas, j'ai tout essayé, avec l'id, avec la valeur, dans un
    # span etc.
    data_form = Hash.new
    # Liste des bonnes réponses
    listecbs = [
      [22,3],
      [17,2],
      [13,0],
      [21,0],
      [19,1],
      [23,2],
      [15,2],
      [14,1],
      [20,3],
      [18,2],
      [16,1]
    ]
    listecbs.each do |arr|
      irep, val = arr
        id = "q8r_rep#{irep}_#{val}"
        li = "li#q-#{irep}-r-#{val}"
      data_form.merge!(
        "--- #{irep} ---" => {type: :radio, in: li, id: id }
      )
    end

    benoit.remplit_le_formulaire('form_quiz-8').
      avec(data_form).
      et_le_soumet('Soumettre')
    shot 'benoit-soumet-quiz'
    sleep 1

    # === TEST ===
    la_page_a_le_soustitre UNAN_SOUS_TITRE_BUREAU
    la_page_a_la_balise('div', id: 'div_note_finale')
    la_page_a_la_balise('span', id: 'note_finale')

    expect(table_resultats.count).to eq nombre_resultats_init + 1
    last_res = table_resultats.select(limit:1, order: 'created_at DESC').first
    # puts "Dernier résultat : #{last_res.inspect}"
    expect(last_res[:user_id]).to eq benoit.id
    success 'Un nouveau résultat a été enregistré pour Benoit'

    expect(benoit.program.points).to be > 0
    expect(benoit.program.points).to eq last_res[:points]
    success 'Benoit a des points pour son programme'

    row_id = last_res[:id]
    hwork = benoit.table_works.select(where: "created_at > #{start_time}").first

    expect(hwork[:item_id]).not_to eq nil
    expect(hwork[:item_id]).to eq row_id
    success 'Le work de Benoit a mémorisé l’id de rangée des résultats'


    # ---------------------------------------------------------------------
    # --- Benoit essaie de re-soumettre son quiz ---
    # Il ne peut pas, un message l'en avertit.

    # TODO En fait, s'arranger plutôt pour que lorsque le quiz
    # a été soumis, et que ce n'est pas un quiz réutilisable, il ne faut
    # pas le ré-afficher. Et pour le moment, l'user ne peut pas le
    # retrouver.


    # Pour afficher le quiz tout frais
    benoit.clique_le_lien 'Revenir à la liste complète'

    benoit.remplit_le_formulaire('form_quiz-8').
      avec(data_form).
      et_le_soumet('Soumettre')
    shot 'benoit-re-soumet-encore-quiz'
    sleep 1
    # sleep 30

    # === TEST ===
    la_page_a_le_soustitre UNAN_SOUS_TITRE_BUREAU

    la_page_a_l_erreur('Vous ne pouvez pas réenregistrer ce questionnaire tout de suite…')
    la_page_napas_la_balise('div', id: 'div_note_finale')

    ben = User.new(benoit.id) # pour être sûr d'avoir un programme frais
    expect(ben.program.points).to eq last_res[:points]
    success 'Benoit a toujours le même nombre de points pour son programme'


  end
end
