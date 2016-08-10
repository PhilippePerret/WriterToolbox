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

    test 'Un administrateur loggué arrive à sa page préférée'

    visit 'http://localhost/WriterToolbox'
    click_link 'S\'identifier'
    la_page_a_le_formulaire 'form_user_login'

    dform = {
      'login_mail'      => {value: data_admin[:mail]} ,
      'login_password'  => {value: data_admin[:password]}
    }
    phil.remplit_le_formulaire(page.find('form#form_user_login')).
      avec(dform).
      et_le_soumet('OK')
    success 'Phil s’identifie.'

    shot 'after-login'

    visit url_edit
    shot 'after-new-url'

    la_page_a_le_formulaire('citation_edit')
    shot('form-edition-citation')

    la_page_a_pour_titre 'Citations d\'auteurs'
    la_page_a_la_balise 'input', type: 'text', value: '181'

  end

  scenario "L'administrateur doit éditer une citation sans être identifié" do

    visit url_edit

    # La page n'est pas celle de l'édition des citations, mais
    # la page d'identification.
    la_page_napas_pour_titre 'Citations d\'auteurs'
    la_page_a_pour_titre 'Identification'
    la_page_a_le_formulaire 'form_user_login'

    # L'URL de destination finale doit être mémorisé dans
    # le formulaire d'identification
    # expect(page).to have_css('input[type="hidden"]', {type: 'hidden'})

    dform = {
      'login_mail'      => {value: data_admin[:mail]} ,
      'login_password'  => {value: data_admin[:password]}
    }
    phil.remplit_le_formulaire(page.find('form#form_user_login')).
      avec(dform).
      et_le_soumet('OK')
    success 'Phil s’identifie.'

    # C'est ici que se passe le test, que l'administrateur doit
    # être redirigé vers la page page.

    # La page est celle de l'édition des citations avec la
    # citation voulue éditée
    la_page_a_le_formulaire 'citation_edit'
    shot('after-redirection')

    la_page_napas_pour_titre 'Identification'
    la_page_a_pour_titre 'Citations d\'auteurs'
    la_page_a_la_balise 'input', type: 'text', value: '181'

  end
end
