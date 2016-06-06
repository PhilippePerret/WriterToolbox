# encoding: UTF-8
=begin

Fichier principal appelé par `hour_cron.rb` à la racine (plus justement,
appelé par ./lib/required.rb en premier).

=end
safed_log "-> #{__FILE__}"

class Cron

  # Si cette constante est mise à true, le safed log qui est
  # composé à chaque run (donc toutes les heures) est transmis
  # à l'administration pour surveillance.
  #
  # C'est important quand de nouveaux processus sont mis en place.
  # d'avoir un retour fréquent.
  #
  # On peut également indiquer une autre fréquence d'envoi à
  # l'aide des valeurs :
  #
  #   2       Toutes les deux heures
  #   3       Toutes les trois heures
  #   4       Toutes les quatre heures
  #   etc.
  #   true    Envoyer toutes les heures
  #   false   Ne jamais envoyer
  #
  #   Noter que jusqu'au chiffre 11 le log sera transmis
  #   plus d'une fois, mais au-dessus de cette valeur, de
  #   12 à 24, il sera envoyé une seule fois mais à l'heure
  #   indiquée par le nombre. 13 => envoi du safed_log à 13
  #   heures.
  #
  SEND_SAFED_LOG = 4


class << self

  def run

    safed_log "-> Cron::run"
    if defined?(APP_FOLDER)
      safed_log "APP_FOLDER = #{APP_FOLDER.inspect}"
    else
      safed_log "APP_FOLDER n'est pas défini…"
    end

    separation = "\n\n" + "-"*70 + "\n"

    # On se place à la racine de l'application pour
    # exécuter toutes les opérations
    # Dir.chdir("/home/boite-a-outils/www/") do
    Dir.chdir(APP_FOLDER) do

      safed_log "Racine dans le Dir.chdir = #{File.expand_path('.')}"

      log "\n\n---> Nettoyage des lieux"
      safed_log "#{separation}[Cron::run] Nettoyage des lieux"
      nettoyage

      # On requiert tout ce qu'il faut requérir
      # Noter que si on n'y parvient pas, l'erreur est fatale,
      # on doit forcément s'arrêter là.
      safed_log "#{separation}[Cron::run] Requérir toutes les librairies du site"
      requerir_les_librairies_du_site

      # Mails d'actualité
      safed_log "#{separation}[Cron::run] Mails d'actualité quotidiens"
      SiteHtml::Updates.annonce_last_updates

      # Voir s'il faut faire un résumé des connexions
      # par IP (en fonction des fréquences)
      log "\n\n---> Traitement des connexions par IP"
      safed_log "#{separation}[Cron::run] Traitement des connexions par IP"
      SiteHtml::Connexions.resume

      log "\n\n---> Envoi des tweets permanents (if needed)"
      safed_log "#{separation} [Cron::run] Envoi des permanent tweets (si nécessaire)"
      SiteHtml::Tweet.send_permanent_tweets_if_needed

      log "\n\n---> Traitement du programme UN AN UN SCRIPT"
      safed_log "#{separation}[Cron::run] Traitement du programme UN AN UN SCRIPT"
      traitement_programme_un_an_un_script

      log "\n\n---> Traitement des messages du forum"
      safed_log "#{separation}[Cron::run] Traitement des messages forum"
      traitement_messages_forum

      log "\n\n--- Fin du cron.run ---"
      safed_log "    = Fin Cron::run ="
    end

  rescue Exception => e
    error_log e rescue nil
  ensure

    # Dans tous les cas, il faut s'assurer que le rapport soit créé et
    # envoyé à l'administrateur.
    safed_log "#{separation}[Cron::run] Traitement du rapport admin"
    begin
      Cron::rapport_admin.traite
    rescue Exception => e
      error_log e, "# Impossible de traiter le rapport administration"
    end


    # Si des erreurs se sont produites, il faut envoyer un mail
    # à l'administrateur pour l'en informer
    SafedErrorLog.send_report_errors if SafedErrorLog.error_occured

    # Si on doit transmettre le safed-log dans son intégralité
    safedlog.send_report if transmit_safed_log?

  end #/run

  def transmit_safed_log?
    case SEND_SAFED_LOG
    when TrueClass  then return true
    when FalseClass then return false
    when Fixnum
      Time.now.hour % SEND_SAFED_LOG == 0
    else
      error_log "La valeur de SEND_SAFED_LOG est inconnue. Il faut soit true, soit false, soit un nombre (Fixnum) de 1 à 24"
    end
  end

  # « Tout est dans le titre. »
  # Noter que c'est la même chose qui est requise par le site au démarrage,
  #
  def requerir_les_librairies_du_site
    safed_log "     -> Cron::requerir_les_librairies_du_site"
    begin
      require "./lib/required"
      safed_log "     <- Cron::requerir_les_librairies_du_site"
    rescue Exception => e
      error_log e, "### IMPOSSIBLE DE CHARGER LES LIBRAIRIES DU SITE"
      log "# Impossible de charger les librairies du site : #{e.message}"
      log e.backtrace.join("\n")
      exit(1)
    end
  end

  # Gestion des nouveaux messages sur le forum
  def traitement_messages_forum
    safed_log "     -> Cron::traitement_messages_forum"
    # Toutes les heures, on vérifie s'il y de nouveaux
    # messages sur le forum, et on envoie les messages
    # d'annonce aux suiveurs (followers) des sujets des
    # messages concernés.
    begin
      Forum::check_new_messages
      safed_log "     <- Cron::traitement_messages_forum"
    rescue Exception => e
      error_log e, "### PROBLÈME EN CHECKANT LES NOUVEAUX MESSAGES SUR LE FORUM"
    end
  end

  # Toute la partie pour gérer les inscrits au programme
  # UN AN UN SCRIPT
  def traitement_programme_un_an_un_script
    safed_log "     -> Cron::traitement_programme_un_an_un_script"
    # L'objet Unan doit être requis pour traiter tout ce qui
    # concerne le programme UN AN UN SCRIPT
    begin
      site.require_objet 'unan'
    rescue Exception => e
      error_log e, "### IMPOSSIBLE DE REQUÉRIR L'OBJET `unan`"
      return false
    end

    # Toutes les heures, voir si des auteurs en activité
    # sur le programme UN AN UN SCRIPT doivent être passés
    # au jour-programme suivant.
    begin
      User::traite_users_unanunscript
      safed_log "     <- Cron::traitement_programme_un_an_un_script"
    rescue Exception => e
      begin
        log "### IMPOSSIBLE DE TRAITER LES AUTEURS DE UN AN UN SCRIPT EN ACTIVITÉ : #{e.message}\n"
        log e.backtrace.join("\n")
      rescue Exception => e
        File.open("./CRON/fatal_error.log", 'wb'){|f| f.write "#{e.message}\n\n" + e.backtrace.join("\n")}
      end
    end
  end # /traitement_programme_un_an_un_script

end #/<<self Cron
end #/Cron

safed_log "<- #{__FILE__}"
