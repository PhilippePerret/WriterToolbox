# encoding: UTF-8
=begin

Tout ce qu'il y a à requérir pour le cron.

Noter que cela ne charge pas le module du site ./lib/required
qui chargera toutes les librairies du site, ce qui sera fait plus tard

=end
begin
  # Requérir tout le dossier ./lib/required
  Dir["#{THIS_FOLDER}/lib/required/**/*.rb"].each{|m| require m}
rescue Exception => e
  log "### IMPOSSIBLE DE CHARGER LES LIBRAIRIES CRON : #{e.message}"
  log "### JE DOIS RENONCER À LANCER LE CRON-JOB"
  exit(1)
end


begin
  Cron::run
rescue Exception => e
  log "### IMPOSSIBLE DE LANCER LE CRON-JOB : #{e.message}"
end
