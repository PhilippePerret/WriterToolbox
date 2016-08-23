=begin

  Test du Jour-programme 5 pour Benoit
  Ce jour-programme utilise un Quiz et permet donc de savoir si les quiz
  fonctionnent bien.
  Pour trouver un quiz qui ne doit pas être enregistré, voir le PDay 27 qui
  utilise le quiz sur la valeur des projets.

=end
feature "Jour-programme 5" do
  before(:all) do
    reset_auteur_unan benoit
    benoit.set_pday_to 5
  end
  scenario "Au PDay 5, Benoit trouve un quiz qu'il peut remplir et soumettre" do
    test "Benoit trouve un quiz, l'affiche, le remplit et le soumet avec succès"

    identify_benoit
    la_page_a_le_soustitre SOUS_TITRE_BUREAU
    benoit.clique_le_lien('Quiz (2)')
    shot 'pday5-onglet-quiz-benoit'
    la_page_a_la_balise('h3', text: 'Quiz')
    la_page_a_la_balise('h4', text: 'Quiz à remplir')
    la_page_a_la_balise('div', id: 'work-25', in: 'section#works_unstarted',
      success: 'La section des travaux à démarrer contient le travail #24 correspondant au quiz #9.')
    la_page_affiche('Répondre à ce questionnaire', in: 'div#work-25',
      success: 'La section contient un bouton pour marquer ce questionnaire vu (et le démarrer).')
    benoit.clique_le_lien('Répondre à ce questionnaire', in: 'div#work-25')
    sleep 10
    # === TEST ===
    # Le questionnaire doit être bien affiché
  end
end
