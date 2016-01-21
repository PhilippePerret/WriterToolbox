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
  # describe 'Unan::Program::Work#depassement' do
  #   before(:all) do
  #     @abswork = Unan::Program::AbsWork::get(@work.id)
  #     @duree_relative = @work.duree_relative.freeze
  #   end
  #   before(:each) do
  #     @work.instance_variable_set('@depassement', nil)
  #   end
  #   it 'répond' do
  #     expect(work).to respond_to :depassement
  #   end
  #   it 'retourne un nombre négatif si aucun dépassement' do
  #     work.set(created_at: NOW - (@duree_relative - 30) )
  #     expect(work.depassement).to be < 0
  #   end
  #   it 'retourne le nombre de secondes de dépassement si dépassé' do
  #     work.set(created_at: NOW - (@duree_relative + 30) )
  #     expect(work.depassement).to be > 0
  #     expect(work.depassement).to eq 30
  #   end
  # end

  #depassement?
  # describe 'Unan::Program::Work#depassement?' do
  #   before(:all) do
  #     @abswork = Unan::Program::AbsWork::get(@work.id)
  #     @duree_relative = @work.duree_relative.freeze
  #   end
  #   before(:each) do
  #     @work.instance_variable_set('@depassement', nil)
  #   end
  #   it 'répond' do
  #     expect(work).to respond_to :depassement?
  #   end
  #   context 'avec un travail qui aurait dû être terminé' do
  #     it 'retourne true' do
  #       work.set(created_at: NOW - (@duree_relative + 10) )
  #       expect(work).to be_depassement
  #     end
  #   end
  #   context 'avec un travail qui doit se terminer plus tard' do
  #     it 'retourne false (n’est pas en dépassement)' do
  #       work.set(created_at: NOW - (@duree_relative - 10))
  #       expect(work).not_to be_depassement
  #     end
  #   end
  # end

  #duree_relative
  describe 'Unan::Program::Work#duree_relative' do
    before(:all) do
      @work     = Unan::Program::Work::get(@program, @program.works.first[:id])
      if @work.abs_work_id.nil?
        @work.set(:abs_work_id => 8)
      end
      expect(@work).not_to eq nil
      expect(@work.abs_work_id).not_to eq nil
      @abs_work = Unan::Program::AbsWork::get(@work.abs_work_id)
      @duree_secondes = @abs_work.duree.days
    end
    before(:each) do
      @work.instance_variable_set('@abs_work', nil)
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

  #set_complete
  describe '#set_complete' do
    before(:each) do
      @old_statuts = @work.get(:status)
      @work.set(status: 0)
      @auteur = @work.program.auteur
      arr = @auteur.get_var(:works_ids, Array::new)
      @auteur.set_var(works_ids: (arr << @work.id).uniq)
      arr = @auteur.get_var(:tasks_ids, Array::new)
      @auteur.set_var(tasks_ids: (arr << @work.id).uniq)
    end
    let(:auteur) { @auteur }
    after(:all) do
      @work.set(status: @old_statuts)
    end
    it 'répond' do
      expect(work).to respond_to :set_complete
    end
    it 'marque le travail terminé' do
      expect(work).not_to be_completed
      work.set_complete
      expect(work).to be_completed
    end
    it 'sort le travail des listes auxquelles il appartenait' do
      expect(auteur.get_var(:works_ids)).to include @work.id
      expect(auteur.get_var(:tasks_ids)).to include @work.id
      work.set_complete
      expect(auteur.get_var(:works_ids)).not_to include @work.id
      expect(auteur.get_var(:tasks_ids)).not_to include @work.id
    end
  end
end
