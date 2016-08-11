# encoding: UTF-8
=begin

Test principal du changement de mot de passe

=end
feature "Changement de mot de passe" do
  def remet_mot_de_passe_de_benoit
    require 'digest/md5'
    require './data/secret/data_benoit.rb' # => DATA_BENOIT
    ben = User.new(2)
    salt = ben.get(:salt)
    cpassword = Digest::MD5.hexdigest("#{DATA_BENOIT[:password]}#{DATA_BENOIT[:mail]}#{salt}")
    ben.set(cpassword: cpassword)
  end
  before(:all) do
    # Dans le cas où il y a eu des problèmes avant, on remet le
    # mot de passe normal de benoit au début des tests
    remet_mot_de_passe_de_benoit
  end
  after(:all) do
    # On remet le mot de passe normal de benoit
    remet_mot_de_passe_de_benoit
  end


  scenario 'Benoit rejoint l’atelier et change son mot de passe' do
    test 'Benoit rejoint le site et change son mot de passe'



    visit home
    la_page_a_la_section 'content'
    la_page_a_le_lien 'S\'identifier'
    click_link('S\'identifier')
    la_page_a_le_formulaire 'form_user_login'
    data_form = {
      'login_mail'      => {value: DATA_BENOIT[:mail]},
      'login_password'  => {value: DATA_BENOIT[:password]}
    }
    benoit.remplit_le_formulaire(page.find('form#form_user_login')).
      avec(data_form).
      et_le_soumet('OK')
    la_page_a_le_message 'Bienvenue, Benoit'

    la_page_a_le_lien 'AUTEUR'
    click_link 'AUTEUR'
    la_page_a_pour_titre 'Votre profil'
    success 'Benoit a rejoint son profil'
    la_page_a_le_lien 'Modifier le mot de passe'
    click_link('Modifier le mot de passe')

    # Benoit se retrouve sur la page de modification
    # du mot de passe
    la_page_a_pour_titre 'Modifier le mot de passe'
    la_page_a_le_formulaire 'form_change_password'

    # Anciennes données de benoit
    old_data = User.new(2).get_all
    $old_data_benoit = old_data # pour la suite
    # puts old_data.inspect

    # Calculer les nouvelles valeurs
    new_password  = 'nouveaumotdepasse'
    salt          = old_data[:salt]
    mail          = old_data[:mail]
    new_cpassword = Digest::MD5.hexdigest("#{new_password}#{mail}#{salt}")
    puts "Nouveau mot de passe crypté : #{new_cpassword}"

    la_page_a_le_formulaire 'form_change_password'
    data_form = {
      'user_mdp' => {value: new_password},
      'user_mdp_confirmation' => {value: new_password}
    }
    benoit.remplit_le_formulaire(page.find('form#form_change_password')).
      avec(data_form).
      et_le_soumet('OK')
    la_page_a_le_message "#{benoit.pseudo}, votre nouveau mot de passe a été enregistré."
    # Nouvelles données de Benoit
    new_data = User.new(2).get_all
    expect(new_data[:cpassword]).not_to eq old_data[:cpassword]
    expect(new_data[:cpassword]).to eq new_cpassword
    success 'La valeur du mot de passe crypté a été modifié'
    # Les autres données ne doivent pas avoir été modifiées
    expect(new_data[:options]).to eq old_data[:options]
    success 'Les autres données sont restées les mêmes.'

    # Benoit se déconnecte
    la_page_a_le_lien 'Déconnexion'
    puts 'Benoit se déconnecte'
    click_link('Déconnexion')
    la_page_affiche 'À très bientôt, Benoit'

  end

  scenario 'Benoit rejoint l’atelier et se connecte avec son nouveau mot de passe' do
    test 'Benoit rejoint l’atelier et se connecte avec son nouveau mot de passe'

    new_password  = 'nouveaumotdepasse'

    visit home
    click_link("S'identifier")
    la_page_a_le_formulaire 'form_user_login'

    # Benoit ne doit pas pouvoir s'identifier avec
    # son ancien mot de passe
    data_form = {
      'login_mail'      => {value: DATA_BENOIT[:mail]},
      'login_password'  => {value: DATA_BENOIT[:password]}
    }
    benoit.remplit_le_formulaire(page.find('form#form_user_login')).
      avec(data_form).
      et_le_soumet('OK')
    la_page_affiche 'Je ne vous reconnais pas'
    la_page_naffiche_pas 'Bienvenue, Benoit'

    # Benoit se reconnecte avec ses bons identifiants
    data_form = {
      'login_mail'      => {value: DATA_BENOIT[:mail]},
      'login_password'  => {value: new_password}
    }
    benoit.remplit_le_formulaire(page.find('form#form_user_login')).
      avec(data_form).
      et_le_soumet('OK')

    la_page_affiche 'Bienvenue, Benoit'

    bdata = User.new(2).get_all
    expect(bdata[:options]).to eq $old_data_benoit[:options]
    options = bdata[:options]
    expect(options).not_to eq nil
    expect(options[2]).to eq '1' # mail confirmé

  end
end
