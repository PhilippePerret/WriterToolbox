=begin

  Module censé tester le current_pday qui permet de savoir où
  l'auteur en est à un moment T (un P-Day) de son programme.

=end
site.require_objet 'unan'
describe 'Jour-programme courant de l’auteur' do
  before(:all) do
    pdata = Unan.table_programs.select.first
    pdata != nil || raise('Impossible de trouver un auteur suivant le programme UN AN UN SCRIPT.')
    up_id = pdata[:auteur_id]
    @program_id = pdata[:id]
    @index_jour_courant = pdata[:current_pday]
    @up_id = up_id
  end
  let(:up) { User.new(@up_id) }
  describe 'current_pday' do
    it 'répond' do
      expect(up).to respond_to :current_pday
    end
    it 'retourne la bonne valeur' do
      expect(up.current_pday).to be_instance_of User::CurrentPDay
    end
  end

  describe 'auteur' do
    it 'répond et retourne l’instance de l’auteur' do
      expect(up.current_pday).to respond_to :auteur
      expect(up.current_pday.auteur.id).to eq up.id
    end
  end
  describe 'program' do
    it 'répond et retourne le programme de l’user' do
      expect(up.current_pday).to respond_to :program
      expect(up.current_pday.program.id).to eq up.program.id
    end
  end
  describe 'day' do
    it 'répond et retourne l’index courant, donc le jour' do
      expect(up.current_pday).to respond_to :day
      expect(up.current_pday.day).to eq @index_jour_courant
    end
  end
end
