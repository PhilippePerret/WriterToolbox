
describe 'Création d’un programme au niveau unitaire' do
  before(:all) do
    @start_time = Time.now.to_i
    site.require_objet 'unan'
    (site.folder_objet+'unan/lib/module/signup/create_program.rb').require
    # => pour Unan::Program::create
    (site.folder_objet+'unan/lib/module/signup/create_projet.rb').require
    # => pour Unan::Projet::create

    # On crée un nouvel user pour pouvoir faire le test
    @user = create_user( :current => true )
    user_id = @user.id
    # puts "Nouvel user : ##{user_id}"

    # ===>  TEST   <===
    program_id = Unan::Program::create
    # puts "program_id créé : #{program_id}"
    projet_id  = Unan::Projet::create
    # puts "projet_id créé : #{projet_id}"
    # ===>  /TEST   <===

    # On essaie de récupérer le programme
    @program = Unan::Program::new(program_id)
  end

  let(:program) { @program }
  let(:user) { @user }

  it 'créé le programme dans la table' do
    expect(program).not_to eq nil
    res = Unan::table_programs.get(program.id)
    expect(res).not_to eq nil
    expect(res[:id]).to eq program.id
  end
  it 'enregistre les bonnes données du programme dans la table' do
    dprog = Unan::table_programs.get(program.id)
    dproj = Unan::table_projets.get(where: "created_at >= #{@start_time}")
    # puts "@start_time = #{@start_time}"
    # puts "dprog : #{dprog.inspect}"
    # puts "dproj : #{dproj.inspect}"
    # puts "TABLE PROGRAMMES"
    # puts Unan::table_programs.select.inspect
    # puts "TABLE PROJETS"
    # puts Unan::table_projets.select.inspect
    expect(dprog[:projet_id]).not_to eq nil
    expect(dprog[:projet_id]).to eq dproj[:id]
    expect(dprog[:auteur_id]).not_to eq nil
    expect(dprog[:auteur_id]).to eq user.id
    expect(dprog[:points]).to eq 0
    expect(dprog[:rythme]).to eq 5
  end
  it 'initie un projet dans la table des projet' do
    dprog = Unan::table_programs.get(program.id)
    res = Unan::table_projets.select(where:"program_id = #{program.id}").values.first
    expect(res).not_to eq nil
    expect(res[:id]).to eq dprog[:projet_id]
  end
  it 'avec les bonnes données pour le projet' do
    dprog = Unan::table_programs.get(program.id)
    res = Unan::table_projets.select(where:"program_id = #{program.id}").values.first
    expect(res).not_to eq nil
    {
      id:           dprog[:projet_id],
      auteur_id:    user.id,
      program_id:   dprog[:id],
      titre:        nil,
      resume:       nil,
      specs:        "000"
    }.each do |key, value|
      expect(res[key]).not_to eq nil unless value.nil?
      expect(res[key]).to eq value
    end
  end
end
