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
      debug "Juste avant de cliquer Démarrer ce travail"
      click_link('Démarrer ce travail')
    end

    expect(page).to have_content('Votre centre de travail')
    debug "Après avoir cliqué sur Démarrer ce travail"
    shot 'after-start-first-work'

    # Un premier work a été enregistré
    expect(table_travaux.count).to eq 1

    # On prend les données du travail pour vérifier
    dwork = table_travaux.select(where: 'created_at > ?', values: [start_time]).first
    expect(dwork[:abs_work_id]) .to eq 8
    expect(dwork[:status])      .to eq 1
    expect(dwork[:abs_pday])    .to eq 1
    expect(dwork[:points])      .to eq 0

    # TODO Un bouton pour finir le travail doit être affiché
    within('div#work-8.work') do
      expect(page).not_to have_link('Démarrer ce travail')
    end
    # TODO La pastille doit avoir changé

    # sleep 60

    shot('panneau-des-taches')

  end
end
