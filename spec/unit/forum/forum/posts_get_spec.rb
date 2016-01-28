describe 'forum.posts.get' do
  before(:all) do
    site.require_objet 'forum'
    degel 'forum-with-messages'
  end
  it 'répond' do
    expect(forum.posts).to respond_to :get
  end

  context 'sans messages' do
    it 'retoure une liste vide' do
      res = forum.posts.get(created_after: NOW + 4.days)
      expect(res).to be_instance_of Array
      expect(res).to be_empty
    end
  end

  context 'avec des messages' do
    it 'retourne la liste des instances Forum::Post' do
      res = forum.posts.get(created_before: NOW)
      expect(res).to be_instance_of Array
      expect(res).not_to be_empty
      res.each do |ipost|
        expect(ipost).to be_instance_of Forum::Post
      end
    end
  end

  describe 'Fonctionnement du filtre' do
    context 'avec un user_id' do
      it 'retourne la liste des messages de l’utilisateur' do
        # Note  On s'assure pour ce test d'avoir un
        # utilisateur avec des messages.
        @nombre_essais = 0
        @liste_users_essayed = Array::new
        begin
          u = get_any_user(but: @liste_users_essayed)
          @liste_users_essayed << u.id
          res = forum.posts.get(user: u)
          raise if res.count == 0
          expect(res).to be_instance_of Array
          res.each do |ipost|
            expect(ipost.user_id).to eq u.id
          end
        rescue Exception => e
          puts "0 messages pour #{u.pseudo}"
          @nombre_essais += 1
          if @nombre_essais > 4
            raise "Impossible de trouver un user avec des messages…"
          else
            retry
          end
        end
      end
    end
  end

end
