
# L'administrateur peut trouver la liste de tous les commentaires à valider

feature "Validation des commentaires de page par l'administrateur" do
  scenario "L'administrateur peut rejoindre la liste des commentaires" do
    identify_phil
    visite_route "page_comments/list?in=site"
    expect(page).to have_tag('h1', text: /Commentaires de pages/)
    expect(page).to have_tag('ul', with: {id: "ul_comments_valided"})
    puts "L'administrateur trouve la liste des commentaires validés"
    expect(page).to have_tag('h3', text: /Commentaires non validés/)
    expect(page).to have_tag('ul', with: {id: 'ul_comments_non_valided'})
    puts "L'administrateur trouve la liste des commentaires non validés"
  end
  def count_valided
    Page::Comments.table.count(where:'options LIKE "1%"')
  end
  def count_non_valided
    Page::Comments.table.count(where:'options LIKE "0%"')
  end
  scenario 'L’administrateur peut valider un commentaire' do
    identify_phil
    visite_route "page_comments/list?in=site"
    count_non_valided_init = count_non_valided
    count_valided_init = count_valided
    within('ul#ul_comments_non_valided > li:nth-child(1)') do
      expect(page).to have_link 'valider'
      click_link 'valider'
    end
    expect(page).to have_tag('h1', text: /Commentaires de pages/)
    expect(page).to have_notice("Commentaire validé.")
    expect(count_valided).to eq count_valided_init + 1
    expect(count_non_valided).to eq count_non_valided_init - 1
  end
end
