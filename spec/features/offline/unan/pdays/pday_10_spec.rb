=begin

  Ce jour permet aussi de tester que Benoit peut revoir un quiz qu'il
  avait réalisé avant et qui n'est plus sur son centre de travail.

=end
feature "10e jour-programme de Benoit" do
  before(:all) do
    reset_auteur_unan benoit
    benoit.set_pday_to(10, {
      # On marque achevés les travaux jusqu'au 9e jour-programme
      complete_upto: 9,
      # Le quiz déjà fait
      quiz: [
        {resultats: TEST_DATA_QUIZ[8][0], pday: 5, awork_id: 25}
      ]
      })
  end
  scenario "Benoit peut revoir le quiz du 5e jour" do
    test 'Benoit peut revoir le quiz du 5e jour, mais sans le refaire'
      start_time = NOW - 1

      # Benoit possède le test fait
      hres = site.dbm_table(:quiz_unan, 'resultats').select(where:{user_id: benoit.id})
      expect(hres).not_to be_empty
      expect(hres.count).to eq 1
      hres = hres.first
      expect(hres[:quiz_id]).to eq 8

      # TODO Benoit se connecte et rejoint l'historique de travail
      identify_benoit
      la_page_a_le_soustitre UNAN_SOUS_TITRE_BUREAU
      la_page_a_le_lien('Historique',
        success: 'La page possède un lien pour rejoindre l’historique de travail')
      benoit.clique_le_lien('Historique')
      la_page_a_le_titre TITRE_PAGE_UNAN
      la_page_a_le_soustitre 'Historique de travail'

      la_page_a_la_balise('ul', id: 'historique',
        success: 'La page affiche la liste de l’historique')
      la_page_a_la_balise('li', id: "li_work-25", class: 'work',
        success: 'La page présente la ligne du travail #25')

      la_page_a_la_balise('a', text: 'voir', in: 'li#li_work-25',
        success: "L'élément présente un lien “voir” pour afficher toutes les données")
      # within('li#li_work-25') do
      #   expect(page).not_to have_css('a', text: "Voir le quiz #8")
      # end
      #
      page.execute_script("UI.scrollTo('li#li_work-25')")

      la_page_a_la_balise('div', class: 'hinfos masked', in: 'li#li_work-25',
        success: 'Le div des infos cachées N’est PAS visible')

      benoit.clique_le_lien('voir', in: 'li#li_work-25')
      begin
        benoit.clique_le_lien('Voir le quiz #8')
      rescue
        page.execute_script("$('li#li_work-25 > a[data-id=\"25\"]').click()")
      end
      sleep 1
      
      la_page_a_pour_titre QUIZ_MAIN_TITRE
      la_page_a_pour_soustitre 'Les Fondamentales'
      expect(page).not_to have_css('div#infos_generales')
      expect(page).not_to have_css('div#quiz_defi')
  end
end
