describe 'Méthodes d’état du work' do
  before(:all) do
    site.require_objet 'unan'
    @program = get_any_program
    @work = Unan::Program::Work::new(@program, @program.table_works.select.keys.first)
    @old_abs_work_id = @work.abs_work_id.freeze
  end

  after(:all) do
    # On remet l'identifiant du départ
    @work.set(abs_work_id: @old_abs_work_id)
  end

  before(:each) do
    [:is_type_task, :abs_work_id, :abs_work].each do |k|
      @work.instance_variable_set("@#{k}", nil)
    end
    [:is_type_task, :type_w].each do |k|
      @work.abs_work.instance_variable_set("@#{k}", nil)
    end
  end

  let(:work)          { @work }

  #task? (raccourci de abs_work)
  describe '#task?' do
    it 'répond' do
      expect(work).to respond_to :task?
    end
    context 'avec un travail de type tâche' do
      before(:each) do
        @abs_work_task_id = Unan::table_absolute_works.select(where:"type_w = 50").keys.first
        @work.set(abs_work_id: @abs_work_task_id)
      end
      it 'un id de work task a été trouvé' do
        expect(@abs_work_task_id).not_to eq nil
      end
      it 'retourne true' do
        expect(work).to be_type_task
      end
    end
    context 'avec un travail qui n’est pas de type tâche' do
      before(:each) do
        @abs_work_not_task_id = Unan::table_absolute_works.select(where:"type_w = 20").keys.first
        # puts "abs_work_not_task_id : #{abs_work_not_task_id.inspect}"
        @work.set(abs_work_id: @abs_work_not_task_id)
      end
      it 'un id de work non task a été trouvé' do
        expect(@abs_work_not_task_id).not_to eq nil
      end
      it 'est lié au bon absolute work' do
        expect(work.abs_work_id).to eq @abs_work_not_task_id
      end
      it 'retourne false' do
        expect(work).not_to be_type_task
      end
    end
  end

  describe '#completed?' do
    it 'répond' do
      expect(work).to respond_to :completed?
    end
    context 'avec un travail terminé' do
      before(:all) do
        @work.set(status: 9)
      end
      it 'retourne true' do
        expect(work).to be_completed
      end
    end
    context 'avec un travail qui n’est pas terminé' do
      before(:all) do
        @work.set(status: 0)
      end
      it 'retourne false' do
        expect(work).not_to be_completed
      end
    end
  end
end
