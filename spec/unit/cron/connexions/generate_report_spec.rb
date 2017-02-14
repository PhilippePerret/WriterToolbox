=begin

Ce fichier ne sert pour le moment qu'à générer le rapport
(et à voir, par conséquent, s'il est produit sans erreur)

IL PERMET ÉGALEMENT DE PRODUIRE LE FICHIER report.css QUI
CONTIENT LES STYLES

=end
describe 'Génération du rapport de connexions' do
  before(:all) do
    Dir['./CRON2/lib/procedure/stats_connexions/**/*.rb'].each{|m| require m}
  end

  describe 'Génération' do
    it 'génère le rapport' do
      Connexions::Connexion.generate_report
      puts "UPLOADER LE FICHIER ./CRON2/lib/procedure/stats_connexions/connexion/class/report.css QUI VIENT D'ÊTRE ACTUALISÉ"
    end
  end
end
