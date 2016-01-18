describe 'Méthodes messages pour l’instanciation d’un nouveau PDay' do
  before(:all) do
    site.require_objet 'unan'
    # Il faut charger l'extention appelée lorsqu'on passe au jour
    # suivant
    (Unan::folder_modules + 'start_pday').require

    # On prend le premier programme qu'on trouve. Normalement,
    # les modifications qu'on opère ici n'affecte pas les programmes
    # existants. Si c'était le cas, il vaudrait mieux créer un nouveau
    # programme
    @program_id = Unan::table_programs.select(colonnes:[:id]).keys.first
    @program = Unan::Program::new(@program_id)
    @index_pday = 1
    @pday = Unan::Program::PDay::new @program, @index_pday
  end
  let(:pday) { @pday }

  describe 'PDay#init_messages_lists' do
    it 'répond' do
      expect(pday).to respond_to :init_messages_lists
    end
    it 'met la variables d’instance @messages_mail à Array::new' do
      pday.instance_variable_set('@messages_mail', nil)
      expect(pday.messages_mail).to eq nil
      pday.init_messages_lists # <=== TEST
      expect(pday.messages_mail).to be_instance_of Array
      expect(pday.messages_mail).to be_empty
    end
    it 'met la variables d’instance @liste_nouveaux_travaux à Array::new' do
      pday.instance_variable_set('@liste_nouveaux_travaux', nil)
      expect(pday.liste_nouveaux_travaux).to eq nil
      pday.init_messages_lists # <=== TEST
      expect(pday.liste_nouveaux_travaux).to be_instance_of Array
      expect(pday.liste_nouveaux_travaux).to be_empty
    end
    it 'met la variable d’instance @liste_travaux_courants à Array::new' do
      pday.instance_variable_set('@liste_travaux_courants', nil)
      expect(pday.liste_travaux_courants).to eq nil
      pday.init_messages_lists # <=== TEST
      expect(pday.liste_travaux_courants).not_to eq nil
      expect(pday.liste_travaux_courants).to be_instance_of Array
      expect(pday.liste_travaux_courants).to be_empty
    end
  end

  describe 'PDay#liste_nouveaux_travaux' do
    it 'peut être défini' do
      pday.liste_nouveaux_travaux = nil
      expect(pday.liste_nouveaux_travaux).to eq nil
      pday.liste_nouveaux_travaux = ["un", "deux", "trois"]
      expect(pday.liste_nouveaux_travaux).to eq ["un", "deux", "trois"]
    end
  end
  describe 'PDay#liste_travaux_courants' do
    it 'peut être définir (accessor)' do
      pday.liste_travaux_courants = nil
      expect(pday.liste_travaux_courants).to eq nil
      pday.liste_travaux_courants = [1,2,3]
      expect(pday.liste_travaux_courants).to eq [1,2,3]
    end
  end
  describe 'add_message_mail' do
    it 'répond' do
      expect(pday).to respond_to :add_message_mail
    end
    it 'ajoute un message à la liste des messages' do
      pday.instance_variable_set('@messages_mail', nil)
      expect(pday.messages_mail).to eq nil
      pday.init_messages_lists
      message = "Ceci est un message pour PDAY à #{Time.now}"
      expect(pday.messages_mail).not_to include message
      pday.add_message_mail message
      expect(pday.messages_mail).to include message
    end
  end
end
