=begin
Test des instances Connexions::SearchEngine
=end
describe 'Connexions::SearchEngine' do
  before(:all) do
    Dir['./CRON2/lib/procedure/stats_connexions/**/*.rb'].each{|m| require m}
  end

  let(:sengine) { @sengine ||= Connexions::SearchEngine.new(:amazone) }
  it 'on peut faire une instance' do
    expect(sengine).to be_instance_of Connexions::SearchEngine
  end

  describe '#human_id' do
    it 'répond' do
      expect(sengine).to respond_to :human_id
    end
    it 'retourne l’identifiant humain' do
      expect(sengine.human_id).to eq :amazone
    end
  end
  describe 'Méthode #name (alias #pseudo)' do
    it 'répond' do
      expect(sengine).to respond_to :name
      expect(sengine).to respond_to :pseudo
    end
    it 'retourne le nom de l’engine' do
      expect(sengine.name).to eq "Amazone Technologies Inc. (Web Service)"
      expect(sengine.pseudo).to eq "Amazone Technologies Inc. (Web Service)"
    end
  end
  describe 'Méthode #short_name (alias #short_pseudo)' do
    it 'répond' do
      expect(sengine).to respond_to :short_pseudo
      expect(sengine).to respond_to :short_name
    end
    it 'retourne le nom court' do
      expect(sengine.short_name).to eq 'Amazon Tech.'
      expect(sengine.short_pseudo).to eq 'Amazon Tech.'
    end
  end

  describe 'Méthode #id' do
    it 'répond' do
      expect(sengine).to respond_to :id
    end
    it 'retourn l’identifiant du moteur de recherche' do
      expect(sengine.id).to eq 37
    end
  end

  describe 'Méthode #ips' do
    it 'répond' do
      expect(sengine).to respond_to :ips
    end
    it 'retourne la liste des adresses IPs' do
      res = sengine.ips
      expect(res).to be_instance_of Array
      expect(res).to include %r{^50\.1[6-9]\.#{ZEROTO255}\.#{ZEROTO255}$}
    end
  end
end
