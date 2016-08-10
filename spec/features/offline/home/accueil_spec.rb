feature "Test de la page d'accueil" do
  scenario "Un visiteur quelconque rejoint la page d'accueil et trouve une page conforme" do
    test 'La page d’accueil présente les liens minimum'

    visit home

    la_page_a_la_balise 'span', text: TITRE_SITE, id: 'site_title'
    la_page_a_le_lien 'S\'inscrire', in: 'section#left_margin'
    la_page_a_le_lien 'S\'identifier', in: 'section#left_margin'
    la_page_a_le_lien 'Contact', in: 'section#footer'

  end
end
