# encoding: UTF-8
=begin
Module qui doit être appelé toutes les heures par le cron-job.

NOTE : Il doit être exécutable.

=end

## En cas de bug récurrent (envoi de rapport en boucle), décommenter la
## ligne suivante et uploader le fichier
# exit

THIS_FOLDER = File.expand_path(File.dirname(__FILE__))
RACINE      = File.expand_path(File.join(THIS_FOLDER, '..'))
ONLINE      = RACINE.split('/').last == "WriterToolbox"
OFFLINE     = !ONLINE

begin

  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # ON NE PEUT PAS APPELER LES MÉTHODES DE MESSAGES/LOG
  # AVANT CETTE LIGNE
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
