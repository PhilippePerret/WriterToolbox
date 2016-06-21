DUSER = TUnan::DUSER

def inscrite
  TUnan.inscrite
end

feature "Test du fonctionnement des pdays" do
  scenario 'Inscrite vient faire son tout premier travail' do

    start_time = Time.now.to_i - 1

    # On refait partir inscrite depuis le premier jour
    TUnan.reset_inscrite( xday = 1 )


    go_and_identify DUSER[:mail], DUSER[:password]

    expect(page).to have_content("Bienvenue, #{DUSER[:pseudo]}")

    shot('after-signin-3e')

    # Pour le moment, aucune préférence n'est réglé pour rejoindre
    # le centre de travail, mais ça pourrait être fait à
    # l'avenir.
    if page.has_link?('rejoindre votre centre de travail')
      click_link('rejoindre votre centre de travail')
    end

    expect(page).to have_content("Le Programme “Un An Un Script”")
    expect(page).to have_css('h2', text: 'Votre centre de travail')
    expect(page).not_to have_css('h3', text: 'Tâches')
    expect(page).to have_link('Tâches')
    click_link('Tâches')
    expect(page).to have_css('h3', text: 'Tâches')

    # Ici, la table des travaux de l'auteur existe, mais aucun
    # travail ne doit avec été encore enregistré
    table_travaux = site.dbm_table(:users_tables, "unan_works_#{inscrite.id}")
    expect(table_travaux).to be_exist
    expect(table_travaux.count).to eq 0

    # Le tout premier travail va être démarré
    expect(page).to have_css('div#work-8.work')
    within('div#work-8.work') do
      expect(page).to have_link('Démarrer ce travail')
      click_link('Démarrer ce travail')
    end

    expect(page).to have_content('Votre centre de travail')
    within('div#work-8') do
      expect(page).to have_link("Marquer ce travail fini")
    end
    shot 'after-start-first-work'

    # Un premier work a été enregistré
    expect(table_travaux.count).to eq 1

    # On prend les données du travail pour vérifier
    dwork = table_travaux.select(where: 'created_at > ?', values: [start_time]).first
    expect(dwork[:abs_work_id]) .to eq 8
    expect(dwork[:status])      .to eq 1
    expect(dwork[:abs_pday])    .to eq 1
    expect(dwork[:points])      .to eq 0

    within('div#work-8.work') do
      expect(page).not_to have_link('Démarrer ce travail')
    end

    # TODO La pastille doit avoir changé

    shot('panneau-des-taches')

  end

  scenario 'Inscrite vient marque son premier travail fini au jour deux' do

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

  scenario 'Le jour suivant, Inscrite trouve de nouveaux travaux' do
    pending "à implémenter"
  end
end
