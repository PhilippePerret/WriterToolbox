=begin

  Test mini ONLINE pour vérifier que les pages minimum peuvent
  être atteintes et que l'identification est possible.

=end
feature "Toutes les pages de base peuvent être atteintes" do

  scenario "Un simple visiteur peut atteindre toutes les pages possibles" do
    visit_home :online => true
    expect(page).to have_css('section#hot_news')
    expect(page).to have_link('OUTILS')
    expect(page).not_to have_css('#flash div.error')

    click_link('OUTILS')
    expect(page).to have_link('Le programme “Un An Un Script”')
    click_link('Le programme “Un An Un Script”', match: :first)
    expect(page).to have_css('h1', text: 'Le Programme “Un An Un Script”')
    expect(page).not_to have_css('#flash div.error')

    click_link('OUTILS')
    expect(page).to have_link('La collection Narration')
    click_link('La collection Narration', match: :first)
    expect(page).to have_css('h1', text: 'La Collection Narration')
    expect(page).not_to have_css('#flash div.error')

    click_link('OUTILS')
    expect(page).to have_link('Les analyses de films')
    click_link('Les analyses de films', match: :first)
    expect(page).to have_css('h1', text: 'Les Analyses de films')
    expect(page).not_to have_css('#flash div.error')

    click_link('OUTILS')
    expect(page).to have_link('Le calculateur de structure')
    click_link('Le calculateur de structure', match: :first)
    expect(page).to have_css('h1', text: 'Le Calculateur de structure')
    expect(page).not_to have_css('#flash div.error')

    click_link('OUTILS')
    expect(page).to have_link('Les didacticiels-vidéo')
    click_link('Les didacticiels-vidéo', match: :first)
    expect(page).to have_css('h1', text: 'Les Didacticiels-vidéo')
    expect(page).not_to have_css('#flash div.error')
    expect(page).to have_css('ul#videos li')

    click_link('OUTILS')
    expect(page).to have_link('La facture d’auteur')
    click_link('La facture d’auteur', match: :first)
    expect(page).to have_css('h1', text: 'La Facture d’auteur')
    expect(page).to have_css('form#form_facture')
    expect(page).not_to have_css('#flash div.error')

    click_link('OUTILS')
    expect(page).to have_link('Les citations d\'auteurs')
    click_link('Les citations d\'auteurs', match: :first)
    expect(page).to have_css('h1', text: 'Citations d\'auteurs')
    expect(page).not_to have_css('#flash div.error')

    click_link('OUTILS')
    expect(page).to have_link('Les citations d\'auteurs')
    click_link('Les citations d\'auteurs', match: :first)
    expect(page).to have_css('h1', text: 'Citations d\'auteurs')
    expect(page).not_to have_css('#flash div.error')

    click_link('OUTILS')
    expect(page).to have_link('Le forum')
    click_link('Le forum', match: :first)
    expect(page).to have_css('h1', text: 'Le Forum')
    expect(page).not_to have_css('#flash div.error')

    click_link('OUTILS')
    expect(page).to have_link('Le Scénodico')
    click_link('Le Scénodico', match: :first)
    expect(page).to have_css('h1', text: 'Le Scénodico')
    expect(page).not_to have_css('#flash div.error')

    click_link('OUTILS')
    expect(page).to have_link('Le Filmodico')
    click_link('Le Filmodico', match: :first)
    expect(page).to have_css('h1', text: 'Le Filmodico')
    expect(page).not_to have_css('#flash div.error')

    expect(page).to have_link('S\'identifier')
    click_link('S\'identifier', match: :first)
    expect(page).to have_css('h1', text: 'Identification')
    expect(page).not_to have_css('#flash div.error')
    expect(page).to have_css('form#form_user_login')

    expect(page).to have_link('S\'inscrire')
    click_link('S\'inscrire', match: :first)
    expect(page).to have_css('h1', 'Inscription')
    expect(page).not_to have_css('#flash div.error')
    expect(page).to have_css('form#form_user_signup')

  end
end
feature "Les pages d'administration ne peuvent pas être atteintes" do
  
  scenario 'Il ne peut pas atteindre l’édition des citations' do
    visit "#{site.distant_url}/citation/12/edit"
    expect(page).to have_css('h1', text: 'Accès interdit')
    expect(page).to have_content('Section réservée à l\'administration.')
  end

  scenario 'Il ne peut pas atteindre le tableau de bord général' do
    visit "#{site.distant_url}/admin/dashboard"
    expect(page).to have_css('h1', text: 'Accès interdit')
    expect(page).to have_content('Section réservée à l\'administration.')
  end

  scenario 'Il ne peut pas atteindre le tableau de bord du programme UN AN UN SCRIPT' do
    visit "#{site.distant_url}/unan_admin/dashboard"
    expect(page).to have_css('h1', text: 'Accès interdit')
    expect(page).to have_content('Section réservée à l\'administration.')
  end

end
