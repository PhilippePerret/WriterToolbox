describe 'forum.sujets.list' do
  before(:all) do
    site.require_objet 'forum'
    degel 'forum-with-messages'
  end

  it 'répond' do
    expect(forum.sujets).to respond_to :list
  end

  context 'avec as: :instance' do
    it 'retourne une liste d’instances Forum::Sujet' do
      res = forum.sujets.list(as: :instance, for: 10)
      expect(res).to be_instance_of Array
      expect(res.count).to eq 10
      expect(res.first).to be_instance_of Forum::Sujet
    end
  end

  context 'avec as: :hash' do
    it 'retourne un hash des paires id<-> hash data' do
      res = forum.sujets.list(as: :hash, for: 7)
      expect(res).to be_instance_of Hash
      expect(res.count).to eq 7
      hdata = res.values.first
      expect(hdata).to be_instance_of Hash
      expect(hdata).to have_key :name
      expect(hdata).to have_key :creator_id
    end
  end

  context 'avec as :data' do
    it 'retourne une liste de hashes de données' do
      res = forum.sujets.list(as: :data, for: 5)
      expect(res).to be_instance_of Array
      expect(res.count).to eq 5
      hdata = res.first
      expect(hdata).to be_instance_of Hash
      expect(hdata).to have_key :name
      expect(hdata).to have_key :creator_id
    end
  end

  context 'avec as: :ids' do
    it 'retourne une liste d’identifiants de sujets' do
      res = forum.sujets.list(as: :ids, for: 8)
      expect(res).to be_instance_of Array
      expect(res.count).to eq 8
      expect(res.first).to be_instance_of Fixnum
      expect(res.last).to be_instance_of Fixnum
    end
  end
end
