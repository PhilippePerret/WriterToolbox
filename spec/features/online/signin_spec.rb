=begin

  Check d'une connexion réussi en online

=end
feature "Connection en ONLINE" do
  scenario "Phil peut rejoindre le site distant et se logguer" do
    require './data/secret/data_phil'
    phil = DATA_PHIL
    visit 'http://www.laboiteaoutilsdelauteur.fr'
    click_link('S\'identifier')
    expect(page).to have_css('form#form_user_login')
    within('form#form_user_login') do
      fill_in('login_mail', with: phil[:mail])
      fill_in('login_password', with: phil[:password])
      click_button('OK')
    end
    # On vérifie
    # Un message d'accueil conforme doit être affiché
    expect(page).to have_content("Bienvenue, Phil")
    # On ne doit pas trouver d'erreur dans la page
    expect(page).not_to have_css('#flash div.error')

    # Déconnexion
    expect(page).to have_link('Déconnexion')
    click_link('Déconnexion')
    expect(page).to have_content('À très bientôt, Phil')


  end

  scenario 'Marion (administratrice) peut se connecter' do
    require './data/secret/data_marion'
    marion = DATA_MARION
    visit 'http://www.laboiteaoutilsdelauteur.fr'
    click_link('S\'identifier')
    expect(page).to have_css('form#form_user_login')
    within('form#form_user_login') do
      fill_in('login_mail', with: marion[:mail])
      fill_in('login_password', with: marion[:password])
      click_button('OK')
    end
    # On vérifie
    # Un message d'accueil conforme doit être affiché
    expect(page).to have_css("#flash div.notice")
    # On ne doit pas trouver d'erreur dans la page
    expect(page).not_to have_css('#flash div.error')

    # Déconnexion
    expect(page).to have_link('Déconnexion')
    click_link('Déconnexion')
    expect(page).to have_content('À très bientôt, Marion')

  end

  scenario 'Marion (administratrice) peut se connecter' do
    require './data/secret/data_benoit'
    benoit = DATA_BENOIT
    visit 'http://www.laboiteaoutilsdelauteur.fr'
    click_link('S\'identifier')
    expect(page).to have_css('form#form_user_login')
    within('form#form_user_login') do
      fill_in('login_mail', with: benoit[:mail])
      fill_in('login_password', with: benoit[:password])
      click_button('OK')
    end
    # On vérifie
    # Un message d'accueil conforme doit être affiché
    expect(page).to have_css('#flash div.notice')
    expect(page).to have_content('Bienvenue, Benoit')
    # On ne doit pas trouver d'erreur dans la page
    expect(page).not_to have_css('#flash div.error')

    # Déconnexion
    expect(page).to have_link('Déconnexion')
    click_link('Déconnexion')
    expect(page).to have_content('À très bientôt, Benoit')

  end

end
