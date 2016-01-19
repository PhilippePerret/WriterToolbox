describe 'Méthodes de Unan::Program::Work' do
  before(:all) do
    site.require_objet 'unan'
    @u = create_user(current:true, unanunscript:true)
    @program = @u.program
    @work_inexistant  = @program.work(10000000000000)
    @work_existant    = @program.work(1)
    @work_existant.create
  end

  let(:work_existant) { @work_existant }
  let(:work_inexistant) { @work_inexistant }

  describe 'Unan::Program::Work#exist?' do
    it 'répond' do
      expect(work_existant).to respond_to :exist?
    end
    context 'avec un travail existant' do
      it 'retourne true' do
        expect(work_existant).to be_exist
      end
    end
    context 'avec un travail inexistant' do
      it 'retourne false' do
        expect(work_inexistant).not_to be_exist
      end
    end
  end
end
