=begin
Analyse des connexions
=end
describe 'Connexions::Connexion' do
  before(:all) do
    Dir['./CRON2/lib/procedure/stats_connexions/**/*.rb'].each{|m| require m}
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
      Connexions::Connexion.analyse
      res = Connexions::Connexion.resultats_analyse
      expect(res).not_to eq nil
      expect(res).to have_key :time
      expect(res).to have_key :per_ip
      expect(res).to have_key :per_route

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

  # ::report
  describe 'Méthode ::report' do
    it 'répond' do
      expect(Connexions::Connexion).to respond_to :report
    end
  end
end
