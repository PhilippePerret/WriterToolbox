=begin
Test de la class Connexions
=end
describe 'Connexions::Connexion' do
  before(:all) do
    Dir['./CRON2/lib/procedure/stats_connexions/**/*.rb'].each{|m| require m}
  end

  # ::get_in_table
  describe 'Méthode ::get_in_table' do
    it 'répond' do
      expect(Connexions::Connexion).to respond_to :get_in_table
    end
  end

  # ::list_upto
  describe 'Méthode ::list_upto' do
    it 'répond' do
      expect(Connexions::Connexion).to respond_to :list_upto
    end
    it 'retourne une liste d’instance Connexions::Connexion' do
      res = Connexions::Connexion.list_upto
      expect(res).to be_instance_of Array
      expect(res.first).to be_instance_of Connexions::Connexion
    end
    it 'retourne seulement la liste voulu, si argument fourni' do
      all = Connexions::Connexion.list_upto.sort_by{|i| i.time}
      count_all = all.count
      jusqua = count_all - 10
      dixieme_temps = all[jusqua].time
      pasall = Connexions::Connexion.list_upto(dixieme_temps)
      expect(pasall.count).to be < all.count
      expect(pasall.count).to eq jusqua
    end
  end

end
