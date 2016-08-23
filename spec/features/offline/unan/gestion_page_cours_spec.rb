feature "Gestion des pages de cours" do
  before(:all) do
    reset_auteur_unan benoit
    benoit.set_pday_to 3
  end
  scenario "Benoit peut marquer “vue” sa page de cours" do
    test 'Benoit peut marquer “vue” sa page de cours'

    start_time = NOW - 1

    # On vérifie que Benoit n'a aucune travail
    expect(benoit.table_works.count).to eq 0
    puts "Benoit n'a aucun travail propre."

    identify_benoit
    la_page_a_pour_titre TITRE_PAGE_UNAN
    la_page_a_pour_soustitre UNAN_SOUS_TITRE_BUREAU
    success "Benoit rejoint son centre de travail"
    # sleep 20
    la_page_a_le_lien 'Cours (4)'
    click_link('Cours (4)')
    la_page_a_la_balise 'h3', text: 'Cours'
    la_page_a_la_section('works_unstarted')
    la_balise('section#works_unstarted').
      contient_la_balise('div', class: 'work', id: "work-3")
    la_page_a_le_lien('Marquer ce travail VU', in: 'section#works_unstarted div#work-3 div.buttons',
      success: "Benoit trouve le bouton “Marquer ce travail VU” pour la première page de cours.")

    benoit.clique_le_lien('Marquer ce travail VU', in: 'section#works_unstarted div#work-3 div.buttons')
    # Benoit doit avoir un travail
    expect(benoit.table_works.count).to eq 1
    success "Benoit a un nouveau travail."

    hwork = benoit.table_works.select.first
    work_id = hwork[:id]
    expect(work_id).not_to eq nil
    puts hwork.inspect
    expect(hwork[:created_at]).to be > start_time
    awork_id = hwork[:abs_work_id]
    hawork = Unan.table_absolute_works.get(awork_id)
    expect(hawork[:item_id]).to eq 3 # la page 3
    puts hawork.inspect
    success "Le travail absolu contient bien l'item id #3 de la page"

    # ---------------------------------------------------------------------
    #   On va s'assurer que la page a été marqué vu
    # ---------------------------------------------------------------------

    la_page_a_pour_titre TITRE_PAGE_UNAN
    la_page_a_pour_soustitre UNAN_SOUS_TITRE_BUREAU

    click_link('Cours (4)')
    la_page_a_la_balise 'h3', text: 'Cours'
    la_page_a_la_section('works_unstarted')
    la_balise('section#current_works').
      contient_la_balise('div', class: 'work', id: "work-3")
    la_page_a_le_lien('Marquer la page lue', in: 'section#current_works div#work-3 div.buttons',
      success: "Benoit trouve le bouton “Marquer la page lu” pour la première page de cours dans la section des travaux courants.")

    # ===== TEST ====
    benoit.clique_le_lien('Marquer la page lue', in: 'div#work-3')

    # ===== VÉRIFICATION =====
    la_page_napas_derreur
    la_page_napas_derreur_fatale
    la_page_a_pour_titre TITRE_PAGE_UNAN
    la_page_a_pour_soustitre UNAN_SOUS_TITRE_BUREAU

    hwork = benoit.table_works.get(work_id)
    expect(hwork[:ended_at]).not_to eq nil
    expect(hwork[:ended_at]).to be > start_time

  end
end
