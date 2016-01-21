describe 'Méthodes Unan::Program pour un travail Work' do
  before(:all) do
    site.require_objet 'unan'
    @user = create_user(current: true, unanunscript:true)
    @program = @user.program
    expect(@program).to be_instance_of Unan::Program
  end
  let(:program) { @program }
  describe 'Unan::Program#work' do
    it 'répond' do
      expect(program).to respond_to :work
    end
    context 'sans argument' do
      it 'produit une erreur fatale' do
        expect{program.work}.to raise_error ArgumentError
      end
    end
    context 'avec un ID nil' do
      it 'retourne nil' do
        expect(program.work(nil)).to eq nil
      end
    end
    context 'avec un ID qui ne correspond à aucun travail propre' do
      it 'retourne une instance work inexistante' do
        res = program.work(10000000000)
        expect(res).to be_instance_of Unan::Program::Work
        expect(res).not_to be_exist
      end
    end
    context 'avec un ID correspond à un travail propre du programme' do
      before(:all) do
        @work_id = 12
        @res = @program.work @work_id
      end
      it 'ne retourne pas nil' do
        expect(@res).not_to eq nil
      end
      it 'retourne une instance Unan::Program::Work' do
        expect(@res).to be_instance_of Unan::Program::Work
      end
      it 'retourne l’instance avec les bonnes données' do
        expect(@res.id).to eq @work_id
      end
    end
  end
end
