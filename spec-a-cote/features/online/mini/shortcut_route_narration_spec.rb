=begin

  Module simple pour tester que la route `narration/<id page>/show` soit
  bien redirigée vers la collection narration

=end
feature "Utilisation du lien raccourci `narration/id/show` pour voir une page narration" do
  scenario "la route narration/id/show conduit à la bonne page narration" do
    visite_route 'narration/300/show', online: true
    expect(page).not_to have_content("la route narration/300/show est inconnue sur ce site")
    expect(page).to have_tag('h1', text: /Collection Narration/)
    expect(page).to have_tag('h2', text: /La Structure/)
    expect(page).to have_tag('div#page_cours h1', text: /#{Regexp.escape "L'incident perturbateur (scène-clé)"}/i)
  end
end
