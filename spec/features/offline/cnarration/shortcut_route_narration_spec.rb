=begin

  Module simple pour tester que la route `narration/<id page>/show` soit
  bien redirigée vers la collection narration

=end
feature "Utilisation du lien raccourci `narration/id/show` pour voir une page narration" do
  scenario "la route narration/id/show conduit à la bonne page narration" do
    test 'La route narration/id/show conduit à la bonne page narration'
    identify_phil # pour voir la page quoi qu'elle soit
    visite_route 'narration/300/show'
    la_page_naffiche_pas 'la route narration/300/show est inconnue sur ce site'
    la_page_a_pour_titre 'Collection Narration'
    la_page_a_pour_soustitre 'La Structure'
    la_page_a_la_balise 'h1', in: 'div#page_cours', text: "L'incident perturbateur (scène-clé)"
  end
end
