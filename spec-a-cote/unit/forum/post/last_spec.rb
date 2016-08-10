describe 'Affichage des derniers messages envoyés' do
  before(:all) do
    site.require_objet('forum') unless defined?(Forum)
    forum.instance_variables.each{|k|forum.remove_instance_variable(k)}
    Forum.instance_variables.each{|k|Forum.remove_instance_variable(k)}
  end
  describe '#last_posts' do
    it 'répond' do
      expect(forum).to respond_to :last_posts
    end
    context 'avec des messages' do
      before(:all) do
        degel 'forum-with-messages'
      end
      it 'affiche les derniers messages' do
        expect(forum.last_posts(as = :li)).to have_tag('li.post')
      end
    end
    context 'sans messages' do
      before(:all) do
        Forum::table_posts.delete(nil, true)
        Forum::table_posts_content.delete(nil,true)
        [:last_posts].each do |k|
          forum.instance_variable_set("@#{k}", nil)
        end
        [:table_posts, :table_posts_content].each do |k|
          Forum::instance_variable_set("@#{k}", nil)
        end
      end
      it 'retourne un texte vide' do
        expect(forum.last_posts(:li)).to be_empty
      end
    end
  end
end
