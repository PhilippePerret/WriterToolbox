# encoding:
=begin
Pseudos et mails récupérés de la version en ligne de Narration
=end
require 'json'
data_file = "./data/divers/adresses_livres_en_ligne.js"
raise "Fichier de données introuvable." unless File.exist?(data_file)
arrdata = JSON.parse(File.open(data_file,'rb'){|f|f.read})

arrdata.each do |hdata|
  puts "Pseudo: #{hdata['pseudo']} / Mail: #{hdata['mail']}"
end
puts "\n\n#{arrdata.count} utilisateurs traités"
