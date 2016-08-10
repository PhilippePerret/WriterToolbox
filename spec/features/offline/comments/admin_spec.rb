
# L'administrateur peut trouver la liste de tous les commentaires à valider

feature "Validation des commentaires de page par l'administrateur" do
  def tablec
    @tablec ||= Page::Comments.table
  end
  scenario "L'administrateur peut rejoindre la liste des commentaires" do
    test 'L’administrateur peut rejoindre la liste des commentaires de pages'
    identify_phil
    visite_route "page_comments/list?in=site"
    la_page_a_pour_titre 'Commentaires de pages'
    la_page_a_la_liste('ul_comments_valided',
      success: 'L’administrateur trouve la liste des commentaires validés')
    la_page_a_la_balise 'h3', text: 'Commentaires non validés'
    la_page_a_la_liste('ul_comments_non_valided',
      success: 'L’administrateur trouve la liste des commentaires non validés')
  end
  def count_valided
    tablec.count(where:'options LIKE "1%"')
  end
  def count_non_valided
    tablec.count(where:'options LIKE "0%"')
  end
  scenario 'L’administrateur peut valider un commentaire' do
    test 'L’administrateur peut valider un commentaire'
    identify_phil
    visite_route "page_comments/list?in=site"
    count_non_valided_init = count_non_valided
    count_valided_init = count_valided
    within('ul#ul_comments_non_valided > li:nth-child(1)') do
      la_page_a_le_lien 'valider'
      click_link 'valider'
    end
    la_page_a_pour_titre 'Commentaires de pages'
    la_page_a_le_message 'Commentaire validé.'
    expect(count_valided).to eq count_valided_init + 1
    expect(count_non_valided).to eq count_non_valided_init - 1
  end
  scenario 'Un non administrateur ne peut pas atteindre la liste des non validés' do
    test 'Un non administrateur ne peut pas atteindre la liste des non validés'
    visite_route 'page_comments/list?in=site'
    la_page_a_pour_titre 'Commentaires de pages'
    la_page_a_la_liste 'ul_comments_valided',
      success: 'L’user trouve la liste des commentaires validés.'
    la_page_napas_la_balise 'h3', text: 'Commentaires non validés'
    la_page_napas_la_liste 'ul_comments_non_valided',
      success: 'L’user ne trouve pas la liste des commentaires non validés.'
  end
  scenario 'Un non administrateur ne peut pas valider un commentaire (en forçant la route)' do
    test 'Un non administrateur ne peut pas valider un commentaire même en forçant la route'
    anti_infini = 0
    begin
      anti_infini += 1
      dcom = tablec.select(where: "options LIKE '0%'").first
      dcom != nil || raise
    rescue Exception => e
      anti_infini < 5 || raise('Impossible de créer des commentaires…')
      create_page_comments 15
      retry
    end
    dcom_id = dcom[:id]
    count_non_valided_init = count_non_valided
    count_valided_init = count_valided
    route = "page_comments/#{dcom_id}/list?in=site&action=valider"
    visite_route route
    la_page_a_le_titre 'Commentaires de pages'
    expect(count_valided).to eq count_valided_init
    expect(count_non_valided).to eq count_non_valided_init
    dcom = Page::Comments.table.get(dcom_id)
    expect(dcom[:options][0]).to eq '0'
    success "L'user n'a pas pu valider le commentaire en forçant l'adresse"
  end
end
