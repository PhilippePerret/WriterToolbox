=begin

Ce fichier ne sert pour le moment qu'à générer le rapport
(et à voir, par conséquent, s'il est produit sans erreur)

=end
describe 'Génération du rapport de connexions' do
  before(:all) do
    Dir['./CRON2/lib/procedure/stats_connexions/**/*.rb'].each{|m| require m}
  end

  describe 'Génération' do
    it 'génère le rapport' do
      Connexions::Connexion.generate_report
    end
  end
end
