# encoding: UTF-8
=begin

Tout ce qu'il y a à requérir pour le cron.

Noter que cela ne charge pas le module du site ./lib/required
qui chargera toutes les librairies du site, ce qui sera fait plus tard

=end
begin
  # On requiert d'abord le module qui permet de loguer les
  # messages
  require "#{THIS_FOLDER}/lib/required/log.rb"
  # Requérir tout le dossier ./lib/required
  Dir["#{THIS_FOLDER}/lib/required/**/*.rb"].each{|m| require m}
rescue Exception => e
  err_message =
    "### IMPOSSIBLE DE CHARGER LES LIBRAIRIES CRON : #{e.message}\n" +
    "### JE DOIS RENONCER À LANCER LE CRON-JOB"
  if respond_to?(:log)
    log err_message
  else
    puts err_message + "\n\n+ ERREUR DANS log.rb, on ne peut pas faire le fichier log."
  end
  # Dans tous les cas, on termine le programme
  exit(1)
end


begin
  Cron::run
rescue Exception => e
  log "### IMPOSSIBLE DE LANCER LE CRON-JOB : #{e.message}"
end
