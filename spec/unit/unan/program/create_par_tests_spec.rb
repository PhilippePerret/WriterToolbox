describe 'Création d’un programme par les tests' do
  before(:all) do
    # degel 'aucun-programme'
    [
      "./database/data/users.db",
      "./database/data/unan_hot.db",
      "./database/data/unan_hot.db.programs.pstore",
      "./database/data/unan"
    ].each do |path|
      sf = SuperFile::new(path)
      sf.remove if sf.exist?
    end
    site.require_objet 'unan'
    reset_all_variables
    reset_variables_unanunscript
  end

  describe 'Création valide avec' do
    before(:all) do
      # On prend les ID de programmes avant
      @init_ids = Unan::table_programs.select(colonnes:[]).keys
      @init_projets_ids = Unan::table_projets.select(colonnes:[]).keys
      @user = create_user(unanunscript: true, current:true)
      @new_ids = Unan::table_programs.select(colonnes:[]).keys
      @new_projets_ids = Unan::table_projets.select(colonnes:[]).keys
      @program_id = @new_ids.reject{|pid| @init_ids.include?(pid)}.first
      puts "@program_id : #{@program_id.inspect}"
      @projet_id  = @new_projets_ids.reject{|pid| @init_projets_ids.include?pid}.first
      puts "@projet_id : #{@projet_id.inspect}"
    end
    let(:user) { @user }
    it 'l’user a été créé' do
      expect(user).to be_instance_of User
    end
    it 'un nouveau programme a été créé dans la table' do
      expect(@init_ids.count).to eq @new_ids.count - 1
    end
    it 'un nouveau projet a été créé dans la table des projets' do
      expect(@init_projets_ids.count).to eq @new_projets_ids.count - 1
    end
    it 'il est inscrit au programme Un AN UN SCRIPT' do
      expect(user).to be_unanunscript
    end
    it 'il possède un programme courant' do
      expect(user.program).to be_instance_of Unan::Program
    end
    it 'le programme doit avoir le bon ID' do
      expect(user.program.id).to eq @program_id
    end
    it 'il possède un projet' do
      if user.projet.nil?
        debug "user.projet est nil, j'essaie de fixer ça"
      end
      expect(user.projet).to be_instance_of Unan::Projet
    end
    it 'le projet doit avoir le bon ID' do
      expect(user.projet.id).to eq @projet_id
    end
    it 'il est au premier jour de son programme' do
      expect(user.program.current_pday).to eq 1
    end
    it 'il possède des travaux' do
      ids = user.get_var(:works_ids)
      expect(ids).to be_instance_of Array
      expect(ids).not_to be_empty
    end
  end
end
