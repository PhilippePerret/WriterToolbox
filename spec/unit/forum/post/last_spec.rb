describe 'Affichage des derniers messages envoyés' do
  before(:all) do
    site.require_objet 'forum'
  end
  describe '#last_posts' do
    it 'répond' do
      expect(forum).to respond_to :last_posts
    end
    context 'avec des messages' do
      before(:all) do
        # TODO Il faut créer des messages
      end
      it 'affiche les derniers messages' do
        expect(forum.last_posts).to have_tag('div#last_posts')
      end
    end
    context 'sans messages' do
      before(:all) do
        # TODO Il faut effacer tous les messages
      end
      it 'affiche un message standard' do
        expect(forum.last_posts).to match "Aucun nouveau message pour le moment"
      end
    end
  end
end
