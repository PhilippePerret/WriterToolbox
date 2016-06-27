# encoding: UTF-8
=begin

Tout ce qu'il y a à requérir pour le cron.

Noter que cela ne charge pas le module du site ./lib/required
qui chargera toutes les librairies du site, ce qui sera fait plus tard

=end

# Pour charger le traitement des messages
# safed
require "#{THIS_FOLDER}/lib/required/logs"

safed_log "-> #{__FILE__}"

safed_log "* STEP 1 (all requirements)"
begin
  # On requiert d'abord le module qui permet de loguer les
  # messages
  safed_log "- Require log.rb"
  require "#{THIS_FOLDER}/lib/required/log.rb"
  # Requérir tout le dossier ./lib/required
  safed_log "- Require toutes les librairies cron"
  Dir["#{THIS_FOLDER}/lib/required/**/*.rb"].each{|m| require m}
  safed_log "= STEP 1 OK ="
rescue Exception => e
  err_message =
    "### IMPOSSIBLE DE CHARGER LES LIBRAIRIES CRON : #{e.message}\n" +
    "### JE DOIS RENONCER À LANCER LE CRON-JOB\n" +
    "### BACKTRACE\n" + e.backtrace.join("\n")
  error_log err_message
  if respond_to?(:log)
    log err_message
  else
    puts err_message + "\n\n+ ERREUR DANS log.rb, on ne peut pas faire le fichier log."
  end
  # Dans tous les cas, on termine le programme
  exit(1)
end


safed_log "* STEP 2 (Cron::run)"
begin
  Cron::run
  safed_log "= STEP 2 OK ="
rescue Exception => e
  error_log e, "PROBLÈME AU COURS DE Cron.run"
end

safed_log "<- #{__FILE__}"
