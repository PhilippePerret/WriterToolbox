# encoding: UTF-8
=begin
Module qui doit être appelé toutes les heures par le cron-job.

NOTE : Il doit être exécutable.

=end

def safed_log mess
  File.open(safed_log_path, 'a') do |f|
    f.write "#{mess}\n"
  end rescue nil
end
def safed_log_path
  @safed_log_path ||= "#{RACINE}/CRON/safed_log.log"
end

THIS_FOLDER = File.expand_path(File.dirname(__FILE__))
RACINE      = File.expand_path(File.join(THIS_FOLDER, '..'))
ONLINE      = RACINE.split('/').last == "WriterToolbox"
OFFLINE     = !ONLINE

File.open("#{THIS_FOLDER}/safed_log.log", 'wb') do |f|
  f.write "SAFED LOG DU #{Time.now.strftime('%d %m %Y - %H:%M')}\n(Ce fichier est un log sûr qui devrait être créé quelles que soient les circonstances)\nRACINE : #{RACINE}\n\n"
end

begin

  # Appel du fichier required.rb qui va accomplir toutes les
  # actions. Note : Ce ne sont pas les librairies du site
  require File.join(THIS_FOLDER, 'lib', 'required.rb')

  # On peut marquer la fin du safed log sans erreur
  safed_log "\n\n=== FIN DU SAFED LOG SANS ERREUR FATALE ==="
rescue Exception => e
  safed_log "\n\nERREUR FATALE : #{e.message}\n"
  safed_log e.backtrace.join("\n")
end

safed_log "--- FIN DU SAFED LOG (#{Time.now.strftime('%d %m %Y - %H:%M')}) ---"

# Si on est arrivé là, on peut détruire le safed-log
# NON ! MAINTENANT, ON A UN RESCUE GÉNÉRAL CI-DESSUS
# File.unlink("#{THIS_FOLDER}/safed_log.log") if File.exist?('./safed_log.log')
