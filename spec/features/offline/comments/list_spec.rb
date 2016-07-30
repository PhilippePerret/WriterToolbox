=begin

  Module de test de l'affichage de tous les commentaires

=end
feature "Affichage de la liste de tous les commentaires" do
  def table
    @table ||= Page::Comments.table
  end
  before(:all) do
    nombre_messages = table.count(where: 'options LIKE "1%"')
    if nombre_messages < 120
      create_page_comments(
        nombre:   120 - nombre_messages,
        valided:  :all
      )
    end
    expect(table.count(where: 'options LIKE "1%"')).to be >= 120
  end
  scenario "Un user voit les commentaires 1 à 49" do
    visite_route 'page_comments/list?in=site'
    expect(page).to have_tag('h1', text: /Commentaires de pages/)
    expect(page).to have_tag('ul', with: {id: "ul_comments_valided"})
    expect(page).to have_css('ul#ul_comments_valided > li:nth-child(20)')
    expect(page).to have_css('ul#ul_comments_valided > li:nth-child(49)')
    expect(page).not_to have_css('ul#ul_comments_valided > li:nth-child(51)')
    puts "les 50 premiers messages sont affichés"
    expect(page).to have_tag('a', with: {href: "page_comments/list?in=site&from_comment=50&to_comment=99"})
  end
  scenario 'Un user peut voir directement les commentaires de 51 à 100 avec les bons boutons' do
    visite_route 'page_comments/list?in=site&from_comment=51&to_comment=100'
  end
end
