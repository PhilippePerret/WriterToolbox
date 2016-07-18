=begin

  Test de redirection après l'identification.

  Synopsis :

    L'administrateur arrive sur le site avec une adresse
    pour éditer une citation.
    Comme il n'est pas identifié, on l'envoie vers le
    formulaire d'identification.
    Il s'identifie correctement.
    Il doit être renvoyé vers l'édition de la citation.

=end
feature "Test d'une redirection après login" do
  let(:url_edit) { 'http://localhost/WriterToolbox/citation/181/edit' }
  let(:data_admin) {
    require './data/secret/data_phil'
    DATA_PHIL
  }

  scenario 'Si l’administrateur est loggué, il arrive directement à l’adresse' do

    visit 'http://localhost/WriterToolbox'
    click_link 'S\'identifier'
    expect(page).to have_css('form#form_user_login')

    # L'administrateur s'identifie
    within('form#form_user_login') do
      fill_in('login_mail', with: data_admin[:mail])
      fill_in('login_password', with: data_admin[:password])
      click_button 'OK'
    end

    shot 'after-login'

    visit url_edit

    shot 'after-new-url'
    expect(page).to have_css('form#citation_edit')
    shot('form-edition-citation')
    expect(page).to have_css('h1', text: 'Citations d\'auteurs')
    # C'est bien la citation voulue qui est éditée
    expect(page).to have_tag('input[type="text"]', {value: '181'})

  end

  scenario "L'administrateur doit éditer une citation sans être identifié" do

    visit url_edit

    # La page n'est pas celle de l'édition des citations, mais
    # la page d'identification.
    expect(page).not_to have_css('h1', text: 'Citations d\'auteurs')
    expect(page).to have_css('h1', text: 'Identification')
    expect(page).to have_css('form#form_user_login')

    # L'URL de destination finale doit être mémorisé dans
    # le formulaire d'identification
    # expect(page).to have_css('input[type="hidden"]', {type: 'hidden'})

    # L'administrateur s'identifie
    within('form#form_user_login') do
      fill_in('login_mail', with: data_admin[:mail])
      fill_in('login_password', with: data_admin[:password])
      click_button 'OK'
    end

    # C'est ici que se passe le test, que l'administrateur doit
    # être redirigé vers la page page.

    # La page est celle de l'édition des citations avec la
    # citation voulue éditée
    expect(page).to have_css('form#citation_edit')
    shot('after-redirection')
    expect(page).not_to have_css('h1', text: 'Identification')
    expect(page).to have_css('h1', text: 'Citations d\'auteurs')
    # C'est bien la citation voulue qui est éditée
    expect(page).to have_tag('input[type="text"]', {value: '181'})


  end
end
