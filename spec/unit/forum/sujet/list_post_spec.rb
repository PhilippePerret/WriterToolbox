describe 'Liste des messages d’un sujet du forum' do
  before(:all) do
    site.require_objet 'forum'

    @sujet = Forum::get_any_sujet # <- Support
  end

  describe '#posts' do
    it 'répond' do
      expect(sujet).to respond_to :posts
    end
    it 'retourne la liste des messages du sujet' do
      res = sujet.posts
      expect(res).to be_instance_of Array
      expect(res.first).to be_instance_of Forum::Post
    end
  end

end
