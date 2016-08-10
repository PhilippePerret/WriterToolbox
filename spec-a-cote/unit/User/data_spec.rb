site.require_objet 'unan'
describe 'Données de l’user' do
  before(:all) do
    @user = create_user
  end
  let(:user) { @user }
  describe 'User#folder' do
    it 'répond' do
      expect(user).to respond_to :folder
    end
    it 'retourne un SuperFile' do
      expect(user.folder).to be_instance_of SuperFile
    end
    it 'retourne le bon path' do
      expect(user.folder.to_s).to eq "./database/data/user/#{user.id}"
    end
  end

  # La base de données propre à l'user
  describe 'user#database' do
    it 'répond' do
      expect(user).to respond_to :database
    end
    it 'retourne une instance BdD' do
      expect(user.database).to be_instance_of BdD
    end
    it 'possède le bon path' do
      expect(user.database.path).to eq "./database/data/user/#{user.id}/data-#{user.id}.db"
    end
  end
end
