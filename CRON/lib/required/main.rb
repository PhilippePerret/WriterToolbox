# encoding: UTF-8
=begin

Fichier principal appelé par `hour_cron.rb` à la racine (plus justement,
appelé par ./lib/required.rb en premier).

=end
class Cron

  def self.run
    # On se place à la racine de l'application pour
    # exécuter toutes les opérations
    Dir.chdir("#{APP_FOLDER}") do

      # On requiert tout ce qu'il faut requérir
      # Noter que si on n'y parvient pas, l'erreur est fatale,
      # on doit forcément s'arrêter là.
      requerir_les_librairies_du_site

      traitement_programme_un_an_un_script

      traitement_messages_forum


    end
  ensure

    # Dans tous les cas, il faut s'assurer que le rapport soit créé et
    # envoyé à l'administrateur.
    # TODO Mettre plutôt le rapport dans Cron que dans Unan
    Unan::rapport_admin.traite

  end #/run

  # « Tout est dans le titre. »
  # Noter que c'est la même chose qui est requise par le site au démarrage,
  #
  def self.requerir_les_librairies_du_site
    begin
      require "./lib/required"
    rescue Exception => e
      log "### IMPOSSIBLE DE CHARGER LES LIBRAIRIES DU SITE : #{e.message}"
      lob "### JE DOIS RENONCER"
      exit(1)
    end
  end

  # Gestion des nouveaux messages sur le forum
  def self.traitement_messages_forum
    log "---> cron.traitement_messages_forum"
    # Toutes les heures, on vérifie s'il y de nouveaux
    # messages sur le forum, et on envoie les messages
    # d'annonce aux suiveurs (followers) des sujets des
    # messages concernés.
    begin
      Forum::check_new_messages
    rescue Exception => e
      log "### PROBLÈME EN CHECKANT LES NOUVEAUX MESSAGES SUR LE FORUM : #{e.message}"
      log e.backtrace.join("\n")
    end
  end

  # Toute la partie pour gérer les inscrits au programme
  # UN AN UN SCRIPT
  def self.traitement_programme_un_an_un_script
    log "---> cron.traitement_programme_un_an_un_script"
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
    rescue Exception => e
      begin
        log "### IMPOSSIBLE DE TRAITER LES AUTEURS DE UN AN UN SCRIPT EN ACTIVITÉ : #{e.message}\n"
        log e.backtrace.join("\n")
      rescue Exception => e
        File.open("./CRON/fatal_error.log", 'wb'){|f| f.write "#{e.message}\n\n" + e.backtrace.join("\n")}
      end
    end
  end # /traitement_programme_un_an_un_script

end
