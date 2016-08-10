=begin

  Module de test des votes

=end
feature "Votes up et down sur les commentaires de page" do
  def tablec
    @tablec ||= Page::Comments.table
  end
  before(:each) do
    whereclause = "route = 'site/test' AND SUBSTRING(options,1,1) = '1'"
    if tablec.count(where: whereclause) < 10
      create_page_comments(
        nombre:   10,
        route:    'site/test',
        valided:  10
      )
    end
    benoit.set_vars(page_comments_ids: [])
  end
  scenario 'Un utilisateur non inscrit ne peut pas voter pour un commentaire' do
    test 'Un simple visiteur ne peut pas voter pour un commentaire'
    visite_route "site/test"

    pcom_id = page.find('ul#ul_page_comments > li:nth-child(4)')[:id]
    pcom_id = pcom_id.split('-').last.to_i

    # On récupère les valeurs du commentaire avant de le modifier
    dcom = Page::Comments.table.get(pcom_id)
    upvotes_init = dcom[:votes_up].freeze
    downvotes_init = dcom[:votes_down].freeze

    la_page_a_le_lien '+1', in: 'ul#ul_page_comments > li:nth-child(4)'
    la_page_a_le_lien '-1', in: 'ul#ul_page_comments > li:nth-child(4)'
    within('ul#ul_page_comments > li:nth-child(4)') do
      click_link '+1'
    end
    puts "Le visiteur clique le bouton +1"
    la_page_a_l_erreur 'Désolé, seuls les visiteurs inscrits peuvent voter.'

    # Le nombre de votes ne doit pas avoir changé
    dcom = Page::Comments.table.get(pcom_id)
    expect(dcom[:votes_up]).to eq upvotes_init
    expect(dcom[:votes_down]).to eq downvotes_init
    success "Les votes du commentaire n'ont pas été modifiés."

  end
  scenario 'Un utilisateur inscrit peut voter (UP) pour un commentaire' do
    test 'Un visiteur inscrit peut voter UP pour un commentaire'
    identify_benoit
    visite_route "site/test"
    pcom_id = page.find('ul#ul_page_comments > li:nth-child(4)')[:id]
    pcom_id = pcom_id.split('-').last.to_i

    # On récupère les valeurs du commentaire avant de le modifier
    dcom = Page::Comments.table.get(pcom_id)
    upvotes_init = dcom[:votes_up].freeze
    downvotes_init = dcom[:votes_down].freeze

    within('ul#ul_page_comments > li:nth-child(4)') do
      click_link '+1'
    end
    puts "Benoit clique sur +1 pour le 4e message."

    # Le update vote doit avoir été enregistré
    la_page_a_le_message("Merci #{benoit.pseudo} pour votre vote.")

    dcom = Page::Comments.table.get(pcom_id)
    expect(dcom[:votes_up]).to eq upvotes_init + 1
    expect(dcom[:votes_down]).to eq downvotes_init
    success "Le commentaire a été upvoté."

  end

  scenario 'Un utilisateur inscrit peut voter (DOWN) pour un commentaire' do
    test 'Un visiteur inscrit peut down-voter pour un commentaire'
    identify_benoit
    visite_route "site/test"
    pcom_id = page.find('ul#ul_page_comments > li:nth-child(3)')[:id]
    pcom_id = pcom_id.split('-').last.to_i

    # On récupère les valeurs du commentaire avant de le modifier
    dcom = Page::Comments.table.get(pcom_id)
    upvotes_init = dcom[:votes_up].freeze
    downvotes_init = dcom[:votes_down].freeze

    within('ul#ul_page_comments > li:nth-child(3)') do
      expect(page).to have_link '+1'
      expect(page).to have_tag('span', with: {class: 'upvotes'}, text: upvotes_init.to_s)
      expect(page).to have_link '-1'
      expect(page).to have_tag('span', with: {class: 'downvotes'}, text: downvotes_init.to_s)
      success "Le commentaire présente bien ses valeurs de votes"
      click_link '-1'
      puts "Benoit clique sur -1 pour le 3e commentaire"
    end

    la_page_a_le_message("Merci #{benoit.pseudo} pour votre vote.")

    # Le update vote doit avoir été enregistré
    dcom = Page::Comments.table.get(pcom_id)
    expect(dcom[:votes_up]).to eq upvotes_init
    expect(dcom[:votes_down]).to eq downvotes_init + 1
    success "Le down-vote a été enregistré pour le commentaire."

    within('ul#ul_page_comments > li:nth-child(3)') do
      expect(page).to have_tag('span', with: {class: 'upvotes'}, text: upvotes_init.to_s)
      expect(page).to have_tag('span', with: {class: 'downvotes'}, text: (downvotes_init + 1).to_s)
      success "Le nombre a été actualisé dans l'affichage du commentaire"
    end

  end


  scenario 'Un utilisateur ne peut pas voter plusieurs fois pour le même commentaire de page' do
    identify_benoit
    visite_route "site/test"
    pcom_id = page.find('ul#ul_page_comments > li:nth-child(2)')[:id]
    pcom_id = pcom_id.split('-').last.to_i

    # On récupère les valeurs du commentaire avant de le modifier
    dcom = Page::Comments.table.get(pcom_id)
    upvotes_init = dcom[:votes_up].freeze
    downvotes_init = dcom[:votes_down].freeze

    within('ul#ul_page_comments > li:nth-child(2)') do
      click_link '+1'
    end

    # Le update vote doit avoir été enregistré
    expect(page).to have_notice("Merci #{benoit.pseudo} pour votre vote.")
    dcom = Page::Comments.table.get(pcom_id)
    expect(dcom[:votes_up]).to eq upvotes_init + 1
    expect(dcom[:votes_down]).to eq downvotes_init

    # ===> TEST <===
    within('ul#ul_page_comments > li:nth-child(2)') do
      click_link '+1'
    end
    # Le update vote NE doit PAS avoir été enregistré
    expect(page).to have_error('Vous ne pouvez voter qu’une seule fois pour un commentaire.')
    dcom = Page::Comments.table.get(pcom_id)
    expect(dcom[:votes_up]).to eq upvotes_init + 1
    expect(dcom[:votes_down]).to eq downvotes_init

  end
end
