=begin

Test des méthodes pour obtenir une page de cours

=end
site.require_objet 'unan'

describe 'Unan::Program::PageCours' do
  before(:all) do
    PC = Unan::Program::PageCours
  end
  describe '::get' do
    it 'répond' do
      expect(PC).to respond_to :get
    end
    context 'avec un argument Fixnum' do
      it 'retourne une instance Unan::Program::PageCours' do
        res = PC::get(1)
        expect(res).to be_instance_of Unan::Program::PageCours
        expect(res.id).to eq 1
      end
    end
    context 'avec un argument Symbol' do
      it 'retourne une instance Unan::Program::PageCours' do
        res = PC::get(:un_handler)
        expect(res).to be_instance_of Unan::Program::PageCours
        expect(res.id).to eq 1
      end
    end
  end

end
