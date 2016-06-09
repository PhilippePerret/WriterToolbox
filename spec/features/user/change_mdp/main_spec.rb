# encoding: UTF-8
=begin

Test principal du changement de mot de passe

=end
feature "Changement de mot de passe" do
  scenario 'Benoit rejoint l’atelier et change son mot de passe' do

    require './data/secret/data_benoit.rb' # => DATA_BENOIT

    visit home
    expect(page).to have_css('section#content')
    expect(page).to have_link("S'identifier")
    click_link('S\'identifier')
    expect(page).to have_css('section#content')
    expect(page).to have_css('form#form_user_login')

    # Benoit s'identifie
    within('form#form_user_login') do
      fill_in('login_mail', with: DATA_BENOIT[:mail])
      fill_in('login_password', with: DATA_BENOIT[:password])
      click_button("OK")
    end

    expect(page).to have_content "Bienvenue, Benoit"

    # Benoit rejoint son profil et clique le lien
    # pour modifier son mot de passe
    expect(page).to have_css('a', text: 'AUTEUR')
    click_link('AUTEUR')
    expect(page).to have_css('h1', text: 'Votre profil')
    expect(page).to have_link('Modifier le mot de passe')
    click_link('Modifier le mot de passe')

    # Benoit se retrouve sur la page de modification
    # du mot de passe
    expect(page).to have_css('h1', text: 'Modifier le mot de passe')
    expect(page).to have_css('form#form_change_password')

    # Anciennes données de benoit
    old_data = User.get(2).get_all
    $old_data_benoit = old_data # pour la suite
    puts old_data.inspect

    require 'digest/md5'
    new_password  = 'nouveaumotdepasse'
    salt          = old_data[:salt]
    mail          = old_data[:mail]
    new_cpassword = Digest::MD5.hexdigest("#{new_password}#{mail}#{salt}")
    puts "Nouveau mot de passe crypté : #{new_cpassword}"

    within('form#form_change_password') do
      fill_in('user_mdp', with: new_password)
      fill_in('user_mdp_confirmation', with: new_password)
      click_button('OK')
    end

    # Nouvelles données de Benoit
    new_data = User.new(2).get_all
    expect(new_data[:cpassword]).not_to eq old_data[:cpassword]
    expect(new_data[:cpassword]).to eq new_cpassword
    # Les autres données ne doivent pas avoir été modifiées
    expect(new_data[:options]).to eq old_data[:options]

    # Benoit se déconnecte
    expect(page).to have_link('Déconnexion')
    click_link('Déconnexion')
    expect(page).to have_content("À très bientôt, Benoit")

  end

  scenario 'Benoit rejoint l’atelier et se connecte avec son nouveau mot de passe' do
    new_password  = 'nouveaumotdepasse'

    visit home
    expect(page).to have_link("S'identifier")
    click_link("S'identifier")
    expect(page).to have_css('form#form_user_login')

    # Benoit ne doit pas pouvoir s'identifier avec
    # son ancien mot de passe
    within('form#form_user_login') do
      fill_in('login_mail', with: DATA_BENOIT[:mail])
      fill_in('login_password', with: DATA_BENOIT[:password])
      click_button("OK")
    end

    expect(page).to have_content "Je ne vous reconnais pas"
    expect(page).not_to have_content "Bienvenue, Benoit"

    # Benoit se reconnecte avec ses bons identifiants
    within('form#form_user_login') do
      fill_in('login_mail',     with: DATA_BENOIT[:mail])
      fill_in('login_password', with: new_password)
      click_button("OK")
    end

    expect(page).to have_content "Bienvenue, Benoit"
    expect(page).to_not have_content "Je ne vous reconnais pas"

    bdata = User.new(2).get_all
    expect(bdata[:options]).to eq $old_data_benoit[:options]
    options = bdata[:options]
    expect(options).not_to eq nil
    expect(options[2]).to eq '1' # mail confirmé
    
  end
end
