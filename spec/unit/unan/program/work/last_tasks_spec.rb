describe 'Unan::Program#last_tasks' do
  before(:all) do
    site.require_objet 'unan'
    @program = get_any_program

  end
  let(:program) { @program }

  it 'répond' do
    expect(program).to respond_to :last_tasks
  end
  context 'avec des tâches récentes' do
    before(:all) do
      # Lui faire des tâches finies récemment
      @program.table_works.execute("UPDATE 'works' SET status = 9")
    end
    it 'il doit y avoir des works' do
      expect(@program.table_works.count).not_to eq 0
    end
    it 'doit y avoir des tasks' do
      taches = @program.works(type: :task)
      expect(taches).not_to be_empty
    end
    it 'retourne la liste des tâches récemment finies' do
      res = program.last_tasks
      expect(res).to be_instance_of Array
      res.each do |w|
        expect(w).to be_instance_of Unan::Program::Work
        expect(w).to be_type_task
      end
    end
  end
  context 'sans tâches récentes finies' do
    before(:all) do
      # Lui retirer toutes les tâches finies récemment
      @program.table_works.execute("UPDATE 'works' SET status = 0")
      [:works, :last_tasks].each do |k|
        @program.instance_variable_set("@#{k}", nil)
      end
    end
    it 'retourne une liste vide' do
      expect(program.last_tasks).to be_empty
    end
  end
end
