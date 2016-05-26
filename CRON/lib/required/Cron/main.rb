# encoding: UTF-8
=begin

Fichier principal appelé par `hour_cron.rb` à la racine (plus justement,
appelé par ./lib/required.rb en premier).

=end
safed_log "-> #{__FILE__}"

class Cron
class << self

  def run

    safed_log "-> Cron::run"
    safed_log "Racine courante = #{File.expand_path('.')}"
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

      safed_log "#{separation}[Cron::run] Nettoyage des lieux"
      nettoyage

      # On requiert tout ce qu'il faut requérir
      # Noter que si on n'y parvient pas, l'erreur est fatale,
      # on doit forcément s'arrêter là.
      safed_log "#{separation}[Cron::run] Requérir toutes les librairies du site"
      requerir_les_librairies_du_site

      # Voir s'il faut faire un résumé des connexions
      # par IP (en fonction des fréquences)
      safed_log "#{separation}[Cron::run] Traitement des connexions par IP"
      SiteHtml::Connexions.resume

      safed_log "#{separation} [Cron::run] Envoi des permanent tweets (si nécessaire)"
      SiteHtml::Tweet.send_permanent_tweets_if_needed

      safed_log "#{separation}[Cron::run] Traitement du programme UN AN UN SCRIPT"
      traitement_programme_un_an_un_script

      safed_log "#{separation}[Cron::run] Traitement des messages forum"
      traitement_messages_forum

      safed_log "    = Fin Cron::run ="
    end
  rescue Exception => e
    safed_log "# ERREUR FATALE : #{e.message}"  rescue nil
    safed_log e.backtrace.join("\n")            rescue nil
  ensure

    # Dans tous les cas, il faut s'assurer que le rapport soit créé et
    # envoyé à l'administrateur.
    # TODO Mettre plutôt le rapport dans Cron que dans Unan
    safed_log "#{separation}[Cron::run] Traitement du rapport admin"
    begin
      Cron::rapport_admin.traite
    rescue Exception => e
      safed_log "# Impossible de traiter le rapport administration : #{e.message}"
      safed_log e.backtrace.join("\n")
    end

  end #/run

  def online?
    @is_online = !offline? if @is_online === nil
  end
  def offline?
    @is_offline = RACINE.split('/').last == "WriterToolbox" if @is_offline === nil
    @is_offline
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
      safed_log "### IMPOSSIBLE DE CHARGER LES LIBRAIRIES DU SITE : #{e.message}"
      safed_log "### JE DOIS RENONCER"
      safed_log e.backtrace.join("\n")
      log "# Impossible de charger les librairies du site : #{e.message}"
      log e.backtrace.join("\n")
      exit(1)
    end
  end

  # Gestion des nouveaux messages sur le forum
  def traitement_messages_forum
    log "\n\n\n---> cron.traitement_messages_forum"
    safed_log "     -> Cron::traitement_messages_forum"
    # Toutes les heures, on vérifie s'il y de nouveaux
    # messages sur le forum, et on envoie les messages
    # d'annonce aux suiveurs (followers) des sujets des
    # messages concernés.
    begin
      Forum::check_new_messages
      safed_log "     <- Cron::traitement_messages_forum"
    rescue Exception => e
      safed_log "### PROBLÈME EN CHECKANT LES NOUVEAUX MESSAGES SUR LE FORUM : #{e.message}"
      safed_log e.backtrace.join("\n")
    end
  end

  # Toute la partie pour gérer les inscrits au programme
  # UN AN UN SCRIPT
  def traitement_programme_un_an_un_script
    log "---> cron.traitement_programme_un_an_un_script"
    safed_log "     -> Cron::traitement_programme_un_an_un_script"
    # L'objet Unan doit être requis pour traiter tout ce qui
    # concerne le programme UN AN UN SCRIPT
    begin
      site.require_objet 'unan'
    rescue Exception => e
      log "### IMPOSSIBLE DE REQUÉRIR L'OBJET `unan` : #{e.message}"
      log "### JE DOIS RENONCER"
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
