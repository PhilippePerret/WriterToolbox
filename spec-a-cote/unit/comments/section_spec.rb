=begin

  Module testant la section des commentaires au niveau du
  code HTML
=end


describe 'Section commentaires de la page' do
  before(:all) do
    set_route 'site/test'
    @code = page.comments
  end
  let(:code) { @code }
  it 'est comprise dans une section#page_comments' do
    expect(code).to have_tag('section', with: {id: 'page_comments'})
  end

  context 'avec un visiteur inscrit' do
    before(:all) do
      User.current= benoit
      @code = page.comments
    end
    it 'contient un formulaire pour faire un commentaire' do
      expect(code).to have_tag('form', with: {id: 'form_page_comments'})
    end
  end
  context 'avec un visiteur non inscrit' do
    before(:all) do
      User.current= nil
      @code = page.comments
    end
    it 'ne contient pas le formulaire pour faire un commentaire' do
      expect(code).not_to have_tag('form', with: {id: 'form_page_comments'})
    end
    it 'contient un lien pour s’inscrire' do
      expect(code).to have_tag('section#page_comments') do
        with_tag 'a', with: {href: BOA.rel_signup_path}
      end
    end
  end

  context 'avec n’importe quel visiteur' do
    before(:all) do
      # S'il n'y a aucun commentaire sur la page site/test,
      # on en créé
      tbl = site.dbm_table(:cold, 'page_comments')
      @dcomments = tbl.select(where:{route: 'site/test'}, order: 'created_at DESC')
    end
    it 'contient une liste des commentaires' do
      expect(code).to have_tag('ul#ul_page_comments')
    end
    it 'affiche tous les commentaires sur la page' do
      @dcomments.each do |hcomment|
        hcomment[:options][0] == '1' || next
        expect(code).to have_tag('ul', with: {id: 'ul_page_comments'}) do
          with_tag 'li', with: {id: "li_pcomment-#{hcomment[:id]}"} do
            # Le pseudo
            with_tag('span', with: {class: 'auteur'}, text: /#{Regexp.escape hcomment[:pseudo]}/)
            # la date
            with_tag('span', with: {class: 'date'}, text: /#{Regexp.escape hcomment[:created_at].as_human_date(true, true, '', 'à')}/)
            # Le commentaire
            with_tag( 'div', with: {class: 'comment'}, text: /#{Regexp.escape hcomment[:comment]}/)
            # Les votes
            with_tag('span', with: {class: 'votesup'}, text: hcomment[:votes_up].to_s)
            with_tag('span', with: {class: 'votesdown'}, text: hcomment[:votes_down].to_s)
          end
        end
      end
    end
  end
end
