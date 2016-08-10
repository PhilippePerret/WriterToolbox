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
    test 'Un user quelconque voit les premiers commentaires'
    visite_route 'page_comments/list?in=site'
    la_page_a_pour_titre 'Commentaires de pages'
    la_page_a_la_liste 'ul_comments_valided',
      success: 'La page présente la liste des commentaires validés'
    la_page_a_la_balise 'ul#ul_comments_valided > li:nth-child(20)',
      success: 'La page affiche le 20e commentaire validé.'
    la_page_a_la_balise 'ul#ul_comments_valided > li:nth-child(49)',
      success: 'La page affiche le 49e commentaire validé.'
    la_page_napas_la_balise 'ul#ul_comments_valided > li:nth-child(51)',
      success: 'La page n’affiche pas le 51e commentaire.'
    la_page_a_la_balise 'a', href: 'page_comments/list?in=site&from_comment=50&to_comment=99',
      success: 'La page affiche le lien pour lire les commentaires suivants.'
  end
  scenario 'Un user peut voir directement les commentaires de 51 à 100 avec les bons boutons' do
    test 'Un user peut voir les commentaires suivants à l’aide des bons paramètres'

    all_comments = Page::Comments.table.select(where: 'SUBSTRING(options,1,1) = "1"', order: 'route')
    bons_comments = [all_comments[51], all_comments[99]]
    bads_comments = [all_comments[49], all_comments[100]]

    visite_route 'page_comments/list?in=site&from_comment=51&to_comment=100'
    la_page_a_pour_titre 'Commentaires de pages'
    la_page_a_la_liste 'ul_comments_valided',
      success: 'La page présente la liste des commentaires validés'

    bads_comments.each do |hcom|
      cid = hcom[:id]
      la_page_napas_la_balise "ul#ul_comments_valided > li#li_pcomment-#{cid}",
        success: "La page n’affiche pas le commentaire validé ##{cid}."
    end
    bons_comments.each do |hcom|
      cid = hcom[:id]
      la_page_a_la_balise "ul#ul_comments_valided > li#li_pcomment-#{cid}",
        success: "La page affiche le commentaire validé ##{cid}."
    end
  end
end
