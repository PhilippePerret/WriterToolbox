# encoding: UTF-8
=begin

Module pour construire le manuel utilisateur du programme UN AN UN SCRIPT

(en attendant de le mettre en console ou de le reconstruire automatiquement)

=end


pmodule = "./objet/unan/aide/manuel/_main_.rb"

require './lib/required'
begin
  require pmodule
  Unan::UManuel::version_femme = true
  Unan::UManuel::build
rescue Exception => e
  puts "# ERREUR : #{e.message}"
  puts e.backtrace.join("\n")
else
  puts "\n\nManuel actualisé avec succès"
end