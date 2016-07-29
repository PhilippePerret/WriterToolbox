=begin

  Module de test de l'affichage de tous les commentaires

=end
feature "Affichage de la liste de tous les commentaires" do
  def table
    @table ||= Page::Comments.table
  end
  before(:all) do
    nombre_messages = table.count(where: 'options LIKE "1%"')
    puts "Nombre de messages : #{nombre_messages}"
    if nombre_messages < 120
      dusers = [
        {pseudo: 'Marion',  id: 3},
        {pseudo: 'Benoite', id: 2},
        {pseudo: 'Phil',    id: 1}
      ]
      routes = ['site/home', 'article/4/show', 'narration/12/show',
        'calcultateur/home', 'cnarration/home', 'forum/home',
        'unan/home'
      ]
      nombre_routes = routes.count
      # On crée pour qu'il y ait 120 messages validés
      (nombre_messages..120).each do |imessage|
        u = dusers[rand(3)]
        ctime = NOW - rand(10000)
        dcom = {
          user_id: u[:id], pseudo: u[:pseudo],
          route: routes[rand(nombre_routes)],
          comment: "Un commentaire numéro #{imessage} de #{u[:pseudo]}",
          options: '10000000',
          created_at: ctime, updated_at: ctime
        }
        table.insert(dcom)
      end
    end
  end
  scenario "Un user voit les commentaires 1 à 49" do
    visite_route 'page_comments/list?in=site'
    expect(page).to have_tag('h1', text: /Commentaires de pages/)
    expect(page).to have_tag('ul', with: {id: "ul_comments_valided"})
    expect(page).to have_css('ul#ul_comments_valided > li:nth-child(20)')
    expect(page).to have_css('ul#ul_comments_valided > li:nth-child(49)')
    expect(page).not_to have_css('ul#ul_comments_valided > li:nth-child(51)')
    puts "les 50 premiers messages sont affichés"
    expect(page).to have_tag('a', with: {href: "page_comments/list?in=site&from_comment=51&to_comment=100"})
  end
  scenario 'Un user peut voir directement les commentaires de 51 à 100 avec les bons boutons' do
    visite_route 'page_comments/list?in=site&from_comment=51&to_comment=100'
  end
end
