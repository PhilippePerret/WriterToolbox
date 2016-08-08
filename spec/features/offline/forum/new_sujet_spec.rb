# encoding: UTF-8
=begin

  Test de la création (réussie ou non) d'un nouveau sujet pour le forum
=end
feature "Création d'un nouveau sujet" do
  # scenario "Un visiteur quelconque ne peut pas créer un nouveau sujet" do
  #   pending 'à implémenter'
  # end
  scenario 'Un visiteur inscrit ne peut pas créer un nouveau sujet' do
    # STDOUT.write '<strong></strong>'
    test 'Un visiteur inscrit ne peut pas créer une nouveau sujet'

    visite_route 'forum/home'
    click_link 'Soumettre'
    la_page_a_pour_soustitre 'Question/sujet'
    la_page_napas_le_formulaire 'form_nouveau_sujet'
    la_page_napas_le_menu 'question_categorie'
    la_page_affiche "vous devez être inscrit pour pouvoir poser une question"
  end
  # scenario 'Un inscript possédant les autorisations nécessaires peut créer un sujet' do
  #   visite_route 'forum/home'
  #   la_page_a_le_lien 'Soumettre'
  #   click_link 'Soumettre'
  #   la_page_a_pour_soustitre 'Question/sujet'
  #   la_page_a_le_formulaire 'form_nouveau_sujet'
  #   la_page_a_le_menu 'question_categorie', in: 'form#form_nouveau_sujet'
  # end
end
