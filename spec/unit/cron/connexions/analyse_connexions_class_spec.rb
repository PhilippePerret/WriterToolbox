=begin
Analyse des connexions
=end
describe 'Connexions::Connexion' do
  before(:all) do
    Dir['./CRON2/lib/procedure/stats_connexions/**/*.rb'].each{|m| require m}
  end

  # ::init_analyse
  describe '::init_analyse' do
    it 'répond' do
      expect(Connexions::Connexion).to respond_to :init_analyse
    end
    it 'reset le tableau des résultats' do
      Connexions::Connexion.analyse # pour renseigner les résultats
      res = Connexions::Connexion.resultats_analyse
      expect(res[:time]).not_to eq nil
      expect(res[:per_ip]).not_to be_empty
      expect(res[:per_route]).not_to be_empty
      Connexions::Connexion.init_analyse
      res2 = Connexions::Connexion.resultats_analyse
      expect(res2[:time]).to eq nil
      expect(res2[:per_ip]).to be_empty
      expect(res2[:per_route]).to be_empty
    end
  end

  # ::analyse
  describe 'Méthode ::analyse' do
    it 'répond' do
      expect(Connexions::Connexion).to respond_to :analyse
    end
    it 'produit l’analyse des connexions' do
      uptime = Time.now.to_i
      Connexions::Connexion.init
      expect(Connexions::Connexion.resultats_analyse).to eq nil
      # On procède à l'analyse
      Connexions::Connexion.analyse
      res = Connexions::Connexion.resultats_analyse
      expect(res).not_to eq nil
      expect(res).to have_key :time
      expect(res).to have_key :per_ip
      expect(res).to have_key :per_route
      expect(res).to have_key :parcours

      # On doit trouver chaque IP en clé de la table :per_ip,
      # sauf TEST
      conns = Connexions::Connexion.get_in_table(uptime)
      expect(conns.count).to be > 0
      puts "Nombre de connexions relevées : #{conns.count}"

      expect(res[:per_ip]).not_to have_key 'TEST'
      conns.each do |conn|
        conn[:ip] != 'TEST' || next
        expect(res[:per_ip]).to have_key conn[:ip]
        expect(res[:per_route]).to have_key conn[:route]
      end

    end
  end
end
