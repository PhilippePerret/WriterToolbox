describe 'forum.posts' do
  before(:all) do
    site.require_objet 'forum'
    degel 'forum-with-messages'
    @nombre_total_messages = Forum::table_posts.count
  end

  describe '#count' do
    it 'répond' do
      expect(forum.posts).to respond_to :count
    end
    context 'avec des messages et sans paramètre' do
      it 'retourne le nombre exact de messages' do
        expect(forum.posts.count).to eq @nombre_total_messages
      end
    end
    context 'avec des messages et des paramètres' do
      before(:all) do
        @un_auteur_forum = ForumSpec::get_any_user
      end
      it 'retourne le nombre de messages répondant au filtre (user_id)' do
        nombre = forum.posts.count(user_id: @un_auteur_forum.id)
        expected = Forum::table_posts.count(where:{user_id: @un_auteur_forum.id})
        expect(nombre).to eq expected
      end
      it 'retourne le nombre de messages répondant au filtre created_after' do
        created_after = NOW - 5.days
        expected  = Forum::table_posts.count(where:"created_at >= #{created_after}")
        nombre    = forum.posts.count(created_after: created_after)
        expect(nombre).to eq expected
      end
      it 'retourne le nombre de messages répondant au filtre created_before' do
        created_before = NOW - 5.days
        expected = Forum::table_posts.count(where:"created_at < #{created_before}")
        expect(forum.posts.count(created_before: created_before)).to eq expected
      end
      it 'retourne nombre de messages répondant au filtre valid: true' do
        expected = Forum::table_posts.count(where:"options LIKE '1%'")
        expect(forum.posts.count(valid: true)).to eq expected
      end
      it 'retourne le nombre de messages répond au filtre valid: false' do
        expected = Forum::table_posts.count(where:"options LIKE '0%'")
        expect(forum.posts.count(valid: false)).to eq expected
      end
      it 'retourne le nombre de messages contenant un texte' do
        str = "crocodile"
        expected = Forum::table_posts_content.count(where:"content LIKE '%#{str}%'")
        expect(forum.posts.count(content: "#{str}")).to eq expected
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
