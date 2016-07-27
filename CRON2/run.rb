# encoding: UTF-8
#
# Fichier qui lance le cronjob
#
# Il a été séparé pour offrir une certitude d'avoir une marque
# de démarrage même en cas de problème.

# Mettre à true pour que le suivi minimum (rflog) soit
# envoyé à l'administrateur. Cela permet de savoir si la
# base a été exécutée avec succès.
SEND_RFLOG_TO_ADMIN = false


# Ici, j'essaie de créer une classe principale pour
# pouvoir mémoriser les choses générales que le message principal
# devra renvoyer.
class MCron
  class << self
    def add_message mess
      @messages ||= []
      @messages << mess
    end
    def messages_formated format = :html
      return nil if @messages.nil?
      delimiteur =
      case format
      when :html then '<br>'
      when :plain then "\n"
      end
      @messages.join(delimiteur)
    end
  end # << self
end #/MCron

# On évite toute incertitude sur le lancement
# en générant un log isolé du reste et qui devrait
# être envoyé à la fin du cron-job.
# TODO : Pour qu'il soit vraiment isolé, il faudrait
# que la procédure d'envoi par mail soit indépendante
# complètement du site, alors que là elle utilise
# encore des procédures du site.
def flog
  @flog ||= begin
    if File.exist?('./www')
      # Distant
      "./www/CRON2/cron2_runner.log"
    elsif File.exist?('./CRON2')
      # Local
      './CRON2/cron2_runner.log'
    else
      './cron2_runner.log'
    end
  end
end

# Le fichier
def rflog
  @rflog ||= File.open(flog, 'a')
end

def putslog mess
  rflog.puts mess
  begin
    MCron.add_message mess
  rescue Exception => e
    # Ici, on pourrait faire quelque chose pour signaler l'erreur
  end
end

# ----------------------------------------------------
#  Début des opérations
#  ---------------------------------------------------


# On détruit le fichier s'il existe
File.unlink flog if File.exist? flog

# On écrit la date du log
putslog "--- CRON2 lancé le #{Time.now}"


begin
  # Charge le cronjob, ce qui l'initie et le lance
  # automatiquement (sauf si CRON_FOR_TEST est à true)
  require_relative 'cronjob'
rescue Exception => e
  putslog "# ERREUR FATALE : #{e.message}"
  putslog e.backtrace.join("\n")
end

begin
  CRON2::SuperLog.send_superlog_if_required
rescue Exception => e
  putslog "# ERREUR À L'ENVOI DU SUPER-LOG : #{e.message}"
  putslog e.backtrace.join("\n")
end

putslog "    CRON2 achevé le #{Time.now}"

# On essaie d'envoyer ça à l'administrateur si
# nécessaire
if SEND_RFLOG_TO_ADMIN
  begin
    # On essaie l'envoi par les messages mémorisés, pas par ceux
    # enregistrés dans le fichier
    site.send_mail_to_admin(
    subject: "CRONJOB DU #{Time.now} - Messages mémorisés",
    message: MCron.messages_formated(:html),
    formated: true
    )
  rescue Exception => e
  end
end
