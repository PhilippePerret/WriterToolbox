describe 'forum.posts.list' do
  before(:all) do
    site.require_objet 'forum'
    degel 'forum-with-messages' # plein de messages
  end

  it 'répond' do
    expect(forum.posts).to respond_to :list
  end

  context 'avec as: :instance' do
    it 'retourne des instances Forum::Post' do
      res = forum.posts.list(as: :instance).first
      expect(res).to be_instance_of Forum::Post
    end
  end

  context 'avec as: :li' do
    it 'retourne un string de li' do
      res = forum.posts.list(as: :li, from: 0, for: 10)
      expect(res).to be_instance_of String
      expect(res).to have_tag('li.post')
    end
  end

  context 'avec as: :hash' do
    it 'retourne un Hash de paire id<->hash de données messages' do
      res = forum.posts.list(as: :hash, for: 10)
      expect(res).to be_instance_of Hash
      expect(res.count).to eq 10
      first = res.values.first
      expect(first).to be_instance_of Hash
      expect(first).to have_key :content
    end
  end

  context 'avec as: :id' do
    it 'retourne une liste d’identifiants de message' do
      res = forum.posts.list(as: :id, for: 10)
      expect(res).to be_instance_of Array
      expect(res.count).to eq 10
      res.each do |pid|
        expect(pid).to be_instance_of Fixnum
      end
    end
  end

  context 'avec as: :data' do
    it 'retourne une liste de Hash de données de posts' do
      res = forum.posts.list(as: :data, for: 9)
      expect(res).to be_instance_of Array
      expect(res.count).to eq 9
      first = res.first
      expect(first).to have_key :content
      expect(first).to have_key :user_id
    end
  end
end
