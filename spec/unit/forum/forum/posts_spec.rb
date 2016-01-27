describe 'forum.posts' do
  before(:all) do
    site.require_objet 'forum'
  end

  describe '#count' do
    it 'répond' do
      expect(forum.posts).to respond_to :count
    end
    context 'avec des messages et sans paramètre' do
      before(:all) do
        Forum::table_posts.delete(nil, true)
        Forum::create_posts(count: 30)
      end
      it 'retourne le nombre exact de messages' do
        expect(forum.posts.count).to eq 30
      end
    end
    context 'avec des messages et des paramètres' do
      before(:all) do
        @un_auteur_forum = Forum::get_any_user
      end
      it 'retourne le nombre de messages répondant au filtre (user_id)' do
        nombre = forum.posts.count(user_id: @un_auteur_forum.id)
        expected = Forum::table_posts.count(where:{user_id: @un_auteur_forum.id})
        expect(nombre).to eq expected
      end
      it 'retourne le nombre de messages répondant au filtre created_after' do
        pending
      end
      it 'retourne le nombre de messages répondant au filtre created_before' do
        pending
      end
      it 'retourne nombre de messages répondant au filtre valid: true' do
        pending
      end
      it 'retourne le nombre de messages répond au filtre valid: false' do
        pending
      end
    end
    context 'sans messages' do
      before(:all) do
        Forum::table_posts.delete(nil, true)
      end
      it 'retourne zéro' do
        expect(forum.posts.count).to eq 0
      end
    end
  end
end
