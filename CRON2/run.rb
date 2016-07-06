# encoding: UTF-8
#
# Fichier qui lance le cronjob
#
# Il a été séparé pour offrir une certitude d'avoir une marque
# de démarrage même en cas de problème.


# On évite toute incertitude sur le lancement
flog =
  if File.exist?('./www')
      # Distant
      "./www/CRON2/cron2_runner.log"
  elsif File.exist?('./CRON2')
     # Local
      './CRON2/cron2_runner.log'
  else
      './cron2_runner.log'
  end

# Le fichier
rflog = File.open(flog, 'wb')

# On écrit la date du log
rflog.puts "CRON2 lancé le #{Time.now}"


begin
  require_relative 'cronjob'
rescue Exception => e
    rflog.puts "# ERREUR FATALE : #{e.message}"
    rflog.puts e.backtrace.join("\n")
end

