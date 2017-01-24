=begin

  Tests pour les connexions

=end
describe 'Connexions::Connexion' do

  before(:all) do
    Dir['./CRON2/lib/procedure/stats_connexions/**/*.rb'].each{|m| require m}
  end

  let(:temps_courant) { @temps_courant ||= Time.now.to_i }
  let(:iconnexion) { Connexions::Connexion.new('site/home', temps_courant, '127.0.0.1') }

  describe 'Méthode #route' do
    it 'répond' do
      expect(iconnexion).to respond_to :route
    end
    it 'retourne la route' do
      expect(iconnexion.route).to eq 'site/home'
    end
  end

  #time
  describe 'Méthode #time' do
    it 'répond' do
      expect(iconnexion).to respond_to :time
    end
    it 'retourne le temps' do
      expect(iconnexion.time).to eq temps_courant
    end
  end

  #ip
  describe 'Méthode #ip' do
    it 'répond' do
      expect(iconnexion).to respond_to :ip
    end
    it 'retourne l’ip de la connexion' do
      expect(iconnexion.ip).to eq '127.0.0.1'
    end
  end

end
