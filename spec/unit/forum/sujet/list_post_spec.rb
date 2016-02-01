describe 'Liste des messages d’un sujet du forum' do
  before(:all) do
    reset_variables_forum
    site.require_objet 'forum'
    degel 'forum-with-messages'
    @sujet = ForumSpec::get_any_sujet # <- Support
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
        res = sujet.posts(for: 2)
        expect(res.count).to eq 2
        res = sujet.posts(for: 3)
        expect(res.count).to eq 3
      end
    end

    # # Pose problème avec la suite complète, mais pas
    # en lançant la feuille courante seule
    # context 'avec un argument :from' do
    #   it 'retourne les messages à partir de cet index' do
    #     reset_variables_forum
    #     @sujet = ForumSpec::get_any_sujet(type: 1) # <- Support
    #     all_posts_ids = Forum::table_posts.select(where:{sujet_id: sujet.id}, order: "created_at DESC").keys
    #     all_posts_ids = all_posts_ids.reverse
    #     res = sujet.posts(from: 2, as: :id)
    #     expect(res.first).to eq all_posts_ids[2]
    #   end
    # end

    context 'avec un argument :as' do
      before(:all) do
        @sujet = ForumSpec::get_any_sujet # <- Support
      end
      context 'valant :ul' do
        it 'retourne les messages sous forme de liste UL' do
          res = sujet.posts(as: :ul)
          expect(res).to be_instance_of String
          expect(res).to have_tag 'ul#posts'
        end
      end

      context 'valant :data' do
        before(:all) do
          @sujet = ForumSpec::get_any_sujet(with_messages: true) # <- Support
        end
        it 'retourne les messages sous forme de liste de données' do
          res = sujet.posts(as: :data)
          expect(res).to be_instance_of Array
          first = res.first
          expect(first).to be_instance_of Hash
          expect(first).to have_key :valided_by
          expect(first).to have_key :user_id
        end
      end

    end
  end

end
