describe 'Méthode de gestion des points de l’auteur' do
  before(:all) do
    site.require_objet 'unan'
    @user = create_user
  end
  let(:user) { @user }
  before(:each) do
    user.instance_variable_set('@total_points', nil)
  end
  describe 'User#total_points' do
    it 'répond' do
      expect(user).to respond_to :total_points
    end
    it 'retourne 0 si aucun point' do
      user.set_var(:total_points, nil)
      expect(user.total_points).to eq 0
    end
    it 'retourne la valeur de points total si elle est définie' do
      user.set_var(:total_points, 122)
      expect(user.total_points).to eq 122
    end
  end

  describe 'User#add_points' do
    it 'répond' do
      expect(user).to respond_to :add_points
    end
    it 'ajoute les points fournis en argument' do
      user.set_var(:total_points, 1000)
      user.add_points 100
      expect(user.get_var(:total_points)).to eq 1100
    end
    it 'n’ajoute pas une valeur nil' do
      user.set_var(:total_points, 500)
      user.add_points nil
      expect(user.get_var(:total_points)).to eq 500
    end
  end
end
