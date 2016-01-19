describe 'Méthodes de Unan::Program::Work' do
  before(:all) do
    site.require_objet 'unan'
    @u = create_user(current:true, unanunscript:true)
    @program = @u.program
    @work = @program.work(8)
    @work.create
  end

  let(:work) { @work }

  #depassement
  describe 'Unan::Program::Work#depassement' do
    before(:all) do
      @abswork = Unan::Program::AbsWork::get(@work.id)
      @duree_relative = @work.duree_relative.freeze
    end
    before(:each) do
      @work.instance_variable_set('@depassement', nil)
    end
    it 'répond' do
      expect(work).to respond_to :depassement
    end
    it 'retourne un nombre négatif si aucun dépassement' do
      work.set(created_at: NOW - (@duree_relative - 30) )
      expect(work.depassement).to be < 0
    end
    it 'retourne le nombre de secondes de dépassement si dépassé' do
      work.set(created_at: NOW - (@duree_relative + 30) )
      expect(work.depassement).to be > 0
      expect(work.depassement).to eq 30
    end
  end

  #depassement?
  describe 'Unan::Program::Work#depassement?' do
    before(:all) do
      @abswork = Unan::Program::AbsWork::get(@work.id)
      @duree_relative = @work.duree_relative.freeze
    end
    before(:each) do
      @work.instance_variable_set('@depassement', nil)
    end
    it 'répond' do
      expect(work).to respond_to :depassement?
    end
    context 'avec un travail qui aurait dû être terminé' do
      it 'retourne true' do
        work.set(created_at: NOW - (@duree_relative + 10) )
        expect(work).to be_depassement
      end
    end
    context 'avec un travail qui doit se terminer plus tard' do
      it 'retourne false (n’est pas en dépassement)' do
        work.set(created_at: NOW - (@duree_relative - 10))
        expect(work).not_to be_depassement
      end
    end
  end

  #duree_relative
  describe 'Unan::Program::Work#duree_relative' do
    before(:all) do
      @abs_work = Unan::Program::AbsWork::get(8)
      @work     = @program.work(8)
      @duree_secondes = @abs_work.duree.days
    end
    it 'répond' do
      expect(work).to respond_to :duree_relative
    end
    context 'avec un rythme moyen' do
      it 'retourne la bonne durée' do
        expect(work.duree_relative).to eq @duree_secondes
      end
    end
    context 'avec un rythme plus lent' do
      before(:all) do
        @program.instance_variable_set('@rythme', 3)
        @program.instance_variable_set('@coefficient_duree', nil)
        @coefficient = 5.0 / 3
        @duree_longue = (@coefficient * @duree_secondes).to_i
        @work.instance_variable_set('@duree_relative', nil)
      end
      it 'le coefficient du programme est bon (juste pour vérification)' do
        expect(@program.coefficient_duree).to eq @coefficient
      end
      it 'retourne une durée plus longue' do
        expect(work.duree_relative).to eq @duree_longue
      end
    end
    context 'avec un rythme plus rapide' do
      before(:all) do
        @program.instance_variable_set('@rythme', 7)
        @program.instance_variable_set('@coefficient_duree', nil)
        @coefficient = 5.0 / 7
        @duree_courte = (@coefficient * @duree_secondes).to_i
        @work.instance_variable_set('@duree_relative', nil)
      end
      it 'le coefficient du programme est bon (juste pour vérification)' do
        expect(@program.coefficient_duree).to eq @coefficient
      end
      it 'retourne une durée plus courte' do
        expect(work.duree_relative).to eq @duree_courte
      end
    end
  end


end
