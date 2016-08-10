DUSER = TUnan::DUSER

def inscrite
  TUnan.inscrite
end

feature "Test du fonctionnement des pdays" do
  scenario 'Inscrite vient faire son tout premier travail' do
    test "DUSER[:pseudo] vient faire son tout premier travail"

    start_time = NOW - 1

    # On refait partir inscrite depuis le premier jour
    reset_auteur_unan inscrite
    inscrite.set_pday_to 1


    go_and_identify( DUSER[:mail], DUSER[:password] )

    la_page_affiche "Bienvenue, #{inscrite.pseudo}"

    shot('after-signin-3e')

    # Pour le moment, aucune préférence n'est réglé pour rejoindre
    # le centre de travail, mais ça pourrait être fait à
    # l'avenir.
    la_page_a_le_lien 'rejoindre votre centre de travail'
    click_link('rejoindre votre centre de travail')

    la_page_a_pour_titre TITRE_PAGE_UNAN
    la_page_a_pour_soustitre 'Votre centre de travail'
    la_page_napas_la_balise 'h3', text: 'Tâches'
    la_page_a_le_lien 'Tâches (1)'
    click_link 'Tâches (1)'
    la_page_a_la_balise 'h3', text: 'Tâches'

    # Ici, la table des travaux de l'auteur existe, mais aucun
    # travail ne doit avec été encore enregistré
    expect(inscrite.table_works.count).to eq 0
    success "#{inscrite.pseudo} n'a pas encore de work propre enregistré."

    # Le tout premier travail va être démarré
    la_page_a_la_balise 'div', id: 'work-8', class: 'work'
    la_page_a_le_lien 'Démarrer ce travail', in: 'div#work-8.work'
    click_link('Démarrer ce travail')
    shot 'after-start-first-work'
    la_page_a_le_lien 'Marquer ce travail fini', in: 'div#work-8'
    success "#{inscrite.pseudo} démarre le travail #8 avec succès."


    # Un premier work a été enregistré
    expect(inscrite.table_works.count).to eq 1
    success "Un nouveau travail (work) a été enregistré pour #{inscrite.pseudo}."

    # On prend les données du travail pour vérifier
    dwork = inscrite.table_works.select(where: 'created_at > ?', values: [start_time]).first
    expect(dwork[:abs_work_id]) .to eq 8
    expect(dwork[:status])      .to eq 1
    expect(dwork[:abs_pday])    .to eq 1
    expect(dwork[:points])      .to eq 0
    la_page_napas_le_lien 'Démarrer ce travail', in: 'div#work-8'
    shot('panneau-des-taches')

  end

  scenario 'Inscrite vient marquer son premier travail fini au jour deux' do

    # NOTE : IL FAUT AVOIR JOUÉ LE TEST PRÉCÉDENT, QUI A
    # INITIALISER INSCRITE

    # Charger toutes les librairies UNAN qui seront utiles,
    # notamment les extensions de la classe User
    site.require_objet 'unan'

    start_time = Time.now.to_i - 1

    go_and_identify DUSER[:mail], DUSER[:password]

    # Pour le moment, l'user ne doit pas avoir de points
    expect( inscrite.points ).to eq 0

    click_link('rejoindre votre centre de travail')
    expect(page).to have_content 'centre de travail'

    click_link('Tâches')
    expect(page).to have_css('h3', text: 'Tâches')
    expect(page).to have_css('div#work-8')
    within('div#work-8') do
      expect(page).to have_link('Marquer ce travail fini')
      click_link('Marquer ce travail fini')
    end

    expect(page).to have_css('h2', text: 'Votre centre de travail')
    expect(page).to have_css('div#work-8')
    shot 'after-mark-fini'

    # Un message annonce la fin
    expect(page).to have_css('#flash div.notice', text: 'Travail #1 terminé (10 nouveaux points).')

    # L'auteur gagne 10 points pour avoir fini son travail
    expect(inscrite.points).to eq 10

    # On prend les données du travail dans la table
    hwork = inscrite.table_works.get( where: {abs_work_id: 8})
    # puts "hwork: #{hwork}"

    # Le travail doit être passé au statut 9
    expect(hwork[:status]).to eq 9
    # Le :ended_at du travail doit avoir été réglé
    expect(hwork[:ended_at]).not_to eq nil
    expect(hwork[:ended_at]).to be > start_time
    # Le nombre de points a été réglé
    expect(hwork[:points]).to eq 10

    # Dans l'affichage
    # Le travail ne doit plus se trouver dans la partie des
    # travaux courants
    within('section#current_works') do
      expect(page).not_to have_css('div#work-8')
    end
    # Le travail doit se trouver dans la partie des travaux
    # terminés
    expect(page).to have_css('section#completed_works')
    expect(page).to have_css('section#completed_works h4', text: 'Tâches récemment achevées')
    within('section#completed_works') do
      expect(page).to have_css('div#work-8')
    end

    # Le nombre de point de inscrite doit avoir augmenté
    click_link('État')
    expect(page).to have_css('h3', text: 'État général du programme')
    shot 'verif-points-actu'
    expect(page).to have_css('span#mark_points', text: '10')

  end

end
