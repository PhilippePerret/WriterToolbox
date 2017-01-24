describe 'Connexions::Route' do
  before(:all) do
    Dir['./CRON2/lib/procedure/stats_connexions/**/*.rb'].each{|m| require m}
  end

  let(:iroute) { @iroute ||= Connexions::Route.new('filmodico/home') }
  let(:temps_courant) { @temps_courant ||= Time.now.to_i }

  describe 'Méthode #add_connexion' do
    it 'répond' do
      expect(iroute).to respond_to :add_connexion
    end
    it 'ajoute une connexion' do
      expect(iroute.connexions).to eq nil
      iconnexion = Connexions::Connexion.new('scenodico/home', temps_courant, '127.0.0.1')
      iroute.add_connexion(iconnexion)
      expect(iroute.connexions).not_to eq nil
      expect(iroute.connexions).to be_instance_of Array
      expect(iroute.connexions.first).to be_instance_of(Connexions::Connexion)
      last = iroute.connexions.last
      expect(last).to be_instance_of Connexions::Connexion
      expect(last.time).to eq temps_courant
      expect(last.route).to eq 'scenodico/home'
      expect(last.ip).to eq '127.0.0.1'
    end
  end
end
