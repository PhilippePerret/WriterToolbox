=begin
=end
def new_connexion_for instance_ip, route = nil, temps = nil
  icon = Connexions::Connexion.new(route || route_au_hasard, temps || time_au_hasard, instance_ip.ip)
end
ROUTES_HASARD = [
  'filmodico/home',
  'scenodico/home',
  'narration/12/show',
  'page/12/show?in=cnarration',
  'calculateur/main',
  'citation/12/show',
  'citation/search',
  'facture/main'
]
NOMBRE_ROUTES_HASARD = ROUTES_HASARD.count
def route_au_hasard
  ROUTES_HASARD[rand(NOMBRE_ROUTES_HASARD)]
end
def time_au_hasard
  Time.now.to_i - rand(10000)
end

describe 'Connexions::IP' do

  before(:all) do
    Dir['./CRON2/lib/procedure/stats_connexions/**/*.rb'].each{|m| require m}
  end

  let(:ip) { @ip ||= Connexions::IP.new('127.0.0.1') }

  describe 'Méthode #ip' do
    it 'répond' do
      expect(ip).to respond_to :ip
    end
    it 'retourne la bonne valeur' do
      expect(ip.ip).to eq '127.0.0.1'
    end
  end

  describe 'Méthode #connexions' do
    it 'répond' do
      expect(ip).to respond_to :connexions
    end
  end

  describe 'Méthode #nombre_connexions' do
    it 'répond' do
      expect(ip).to respond_to :nombre_connexions
    end
    it 'retourne le nombre de connexions' do
      instip = Connexions::IP.new('127.0.0.1')
      expect(instip.nombre_connexions).to eq 0
      (1..5).each do |nombre|
        instip.add_connexion(new_connexion_for(instip))
        expect(instip.nombre_connexions).to eq nombre
      end
    end
  end

  describe 'Méthode #add_connexion' do
    let(:temps_courant) { @temps_courant ||= Time.now.to_i }
    let(:iconnexion) { @iconnexion ||= Connexions::Connexion.new('filmodico/list', temps_courant, '127.0.0.1') }
    it 'répond' do
      expect(ip).to respond_to :add_connexion
    end
    it 'ajoute une connexion' do
      nombre_connexions = ip.connexions.count
      ip.add_connexion iconnexion
      expect(ip.connexions.count).to eq nombre_connexions + 1
    end
  end

  describe 'Méthode #start_time' do
    it 'répond' do
      expect(ip).to respond_to :start_time
    end
  end
  describe 'Méthode #end_time' do
    it 'répond' do
      expect(ip).to respond_to :end_time
    end
  end
  describe '#duree_connexion' do
    it 'répond' do
      expect(ip).to respond_to :duree_connexion
    end
    it 'retourne la durée de connexion en nombre de secondes' do
      ip.instance_variable_set('@start_time', 10)
      ip.instance_variable_set('@end_time', 100)
      expect(ip.duree_connexion).to eq 90
    end
  end
  describe '#human_duree_connexion' do
    it 'répond' do
      expect(ip).to respond_to :human_duree_connexion
    end
    it 'retourne la durée humaine de connexion de l’IP' do
      ip.instance_variable_set('@start_time', 10)
      ip.instance_variable_set('@end_time', 100)
      expect(ip.human_duree_connexion).to eq '1\'30"'
      ip.instance_variable_set('@start_time', 10)
      ip.instance_variable_set('@end_time', 3600 + 100)
      ip.instance_variable_set('@duree_connexion', nil)
      ip.instance_variable_set('@human_duree_connexion', nil)
      expect(ip.human_duree_connexion).to eq '1h01\'30"'
    end
  end

  describe 'Méthode #search_engine?' do
    it 'répond' do
      expect(ip).to respond_to :search_engine?
    end
    it 'retourne true si c’est un moteur de recherche' do
      ip = Connexions::IP.new('17.0.0.0') # Apple
      expect(ip).to be_search_engine
    end
    it 'retourne false si ça n’est pas un moteur de recherche' do
      ip = Connexions::IP.new('147.100.111.155')
      expect(ip).not_to be_search_engine
    end
  end

  describe 'Méthode #search_engine' do
    it 'répond' do
      expect(ip).to respond_to :search_engine
    end
    it 'retourne nil pour une IP qui n’est pas un moteur de recherche' do
      ip = Connexions::IP.new('147.100.111.155')
      expect(ip.search_engine).to be nil
    end
    it 'retourne une instance SearchEngine pour une IP de moteur de recherche' do
      ip = Connexions::IP.new('17.0.0.0') # Apple
      se = ip.search_engine
      expect(se).not_to be nil
      expect(se).to be_instance_of Connexions::SearchEngine
      expect(se.name).to eq 'Apple'
      expect(se.id).to eq 33
    end
  end
end
