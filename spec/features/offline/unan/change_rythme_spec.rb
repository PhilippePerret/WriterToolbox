feature "Changement de rythme" do
  before(:each) do
    reset_auteur_unan benoit
    benoit.set_pday_to 3
  end
  scenario "Benoit peut changer son rythme de travail par l'onglet préférences" do
    test 'Benoit peut changer son rythme de travail par le panneau Préférences'
    start_time = NOW - 1
    expect(benoit.program.rythme).to eq 5

    # === TEST ===
    identify_benoit
    la_page_a_pour_titre TITRE_PAGE_UNAN
    la_page_a_pour_soustitre SOUS_TITRE_BUREAU
    la_page_napas_la_balise('h3', text: 'Préférences',
      success: 'L’onglet “Préférences” n’est pas affiché.')
    benoit.clique_le_lien('Préférences')
    la_page_a_la_balise('h3', text: 'Préférences',
      success: 'L’onglet ”Préférences” est affiché.')
    la_page_a_le_formulaire('preferences')
    benoit.remplit_le_formulaire('preferences').
      avec('pref_rythme' => {type: :select, value: 'soutenu'}).
      et_le_soumet('Enregistrer')

    # Pour attendre que la page se réaffiche
    la_page_a_pour_titre TITRE_PAGE_UNAN
    la_page_a_pour_soustitre SOUS_TITRE_BUREAU

    # === VÉRIFICATIONS ===
    # La donnée du programme doit avoir été modifiée dans la table
    hprog = Unan.table_programs.get(benoit.program.id)
    expect(hprog[:rythme]).to eq 6
    success "La donnée :rythme a été changée dans la table des programmes"
    # L'instance du programme doit retourner la nouvelle valeur
    expect(benoit.program.rythme).to eq 6
    success 'L’instance du programme de Benoit a la bonne valeur'
  end
  # /Scénario du changement de rythme enregistré

  scenario 'Quand Benoit change de rythme, tous les panneaux reflètent le changement' do
    test 'Un changement de rythme se reflète sur tous les panneaux (Préférences et État)'
    start_time = NOW - 1
    expect(benoit.program.rythme).to eq 5

    identify_benoit
    la_page_a_pour_soustitre SOUS_TITRE_BUREAU

    benoit.clique_le_lien('État')
    la_page_a_la_balise('h3', text: 'État général du programme')
    la_page_a_la_balise('span', text: 'moyen',
      success: 'Le panneau “État” affiche le bon rythme (moyen).'
      )

    # === TEST ===
    benoit.clique_le_lien('Préférences')
    la_page_a_la_balise('h3', text: 'Préférences',
      success: 'L’onglet ”Préférences” est affiché.')
    benoit.remplit_le_formulaire('preferences').
      avec('pref_rythme' => {type: :select, value: 'rapide'}).
      et_le_soumet('Enregistrer')

    # Pour attendre que la page se réaffiche
    la_page_a_pour_titre TITRE_PAGE_UNAN
    la_page_a_pour_soustitre SOUS_TITRE_BUREAU

    # === VÉRIFICATIONS ===
    # La donnée du programme doit avoir été modifiée dans la table
    hprog = Unan.table_programs.get(benoit.program.id)
    expect(hprog[:rythme]).to eq 7
    success "La donnée :rythme a été changée dans la table des programmes"
    # L'instance du programme doit retourner la nouvelle valeur
    expect(benoit.program.rythme).to eq 7
    success 'L’instance du programme de Benoit a la bonne valeur'

    benoit.clique_le_lien('État')
    la_page_a_la_balise('h3', text: 'État général du programme')
    la_page_a_la_balise('span', text: 'rapide',
      success: 'Le panneau “État” affiche le bon rythme (rapide).'
      )

  end


end
