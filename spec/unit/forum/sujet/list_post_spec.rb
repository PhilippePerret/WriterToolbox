describe 'Liste des messages d’un sujet du forum' do
  before(:all) do
    site.require_objet 'forum'
    degel 'forum-with-messages'
    @sujet = Forum::get_any_sujet # <- Support
  end

  let(:sujet) { @sujet }

  describe '#posts' do
    it 'répond' do
      expect(sujet).to respond_to :posts
    end
    context 'sans argument' do
      it 'retourne la liste des messages du sujet' do
        res = sujet.posts
        expect(res).to be_instance_of Array
        expect(res.first).to be_instance_of Forum::Post
      end
    end

    context 'avec un argument :for' do
      it 'retourne le nombre de messages demandés' do
        res = sujet.posts(for: 5)
        expect(res.count).to eq 5
        res = sujet.posts(for: 3)
        expect(res.count).to eq 3
      end
    end

    context 'avec un argument :from' do
      it 'retourne les messages à partir de cet index' do
        all_posts_ids = Forum::table_posts.select(where:{sujet_id: sujet.id}, order: "created_at DESC").keys
        res = sujet.posts(from: 2, as: :id)
        expect(res.first).to eq all_posts_ids[2]
      end
    end

    context 'avec un argument :as' do

      context 'valant :ul' do
        it 'retourne les messages sous forme de liste UL' do
          res = sujet.posts(as: :ul)
          expect(res).to be_instance_of String
          expect(res).to have_tag 'ul#posts'
        end
      end

      context 'valant :data' do
        it 'retourne les messages sous forme de liste de données' do
          res = sujet.posts(as: :data)
          expect(res).to be_instance_of Array
          first = res.first
          expect(first).to be_instance_of Hash
          expect(first).to have_key :content
          expect(first).to have_key :user_id
        end
      end

    end
  end

end
