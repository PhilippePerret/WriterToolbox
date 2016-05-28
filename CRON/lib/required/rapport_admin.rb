# encoding: UTF-8
safed_log "-> #{__FILE__}"

require 'singleton'

class Cron

  class << self

    def rapport_admin
      @rapport_admin ||= RapportAdmin.instance
    end
    alias :report :rapport_admin

  end # << self

  # ---------------------------------------------------------------------
  #   Class pour la gestion du mail administrateur
  # ---------------------------------------------------------------------
  class RapportAdmin

    include Singleton

    # SI true, ne reçoit le rapport qu'une fois par jour
    # Si false, reçoit le rapport toutes les heures
    RAPPORT_ADMIN_ONCE_A_DAY = true

    attr_accessor :rapport_administration
    attr_accessor :depassements


    # Pour pouvoir utiliser la syntaxe :
    #   Cron::Admin::report << message
    # Noter que le texte est ajouté à un fichier Markdown pour le moment
    # donc qu'on peut envoyer du code markdown
    def << message
      path_mail_erb.append( "#{message}\n\n")
    end

    # = main =
    #
    # Méthode appelée par le main du cron-job pour envoyer le
    # message administration si nécessaire.
    #
    # Traitement du rapport. Soit on l'envoie, soit on l'enregistre
    # dans un fichier en attendant de l'envoyer en début de journée
    def traite

      # Noter que même si le rapport courant est nil, il faut
      # traiter la méthode, car il est peut-être temps d'envoyer
      # tous les rapports qui ont été consignés dans le fichier
      # au cours de la journée.
      return if RAPPORT_ADMIN_ONCE_A_DAY && Time.now.hour != 0

      # On enregistre le rapport mis en forme dans le fichier,
      # s'il existe, car c'est ce fichier qui sera lu et mis
      # dans le mail
      # Noter qu'il existe toujours puisqu'on ajoute au
      # bout le log. Ce log témoigne de tout ce qui a
      # été fait au cours du cron job.
      path_rapport_admin.write rapport_mis_en_forme
      log "Rapport administration consigné dans un fichier"

      # Envoyer le rapport
      if send_rapport
        safed_log "    = Rapport administrateur envoyé."
        path_rapport_admin.remove if path_rapport_admin.exist?
        path_mail_erb.remove      if path_mail_erb.exist?
      end

    end

    # {String} Retourn le rapport mis en forme
    def rapport_mis_en_forme
      @rapport_mis_en_forme ||= begin
        c = ""

        # Tous les messages consignés au cours des cron-jobs
        # successifs
        suivi = if path_mail_erb.exist?
          path_mail_erb.deserb
        else
          ""
        end

        # Message assemblé
        "<h2>Rapport administration #{ONLINE ? 'ONLINE' : 'OFFLINE'} du cronjob du #{NOW.as_human_date(true, true, ' ')}</h2>"+
        suivi +
        "<hr />" +
        log_content.in_pre(class:'small')
      end
    end

    # Retourne le contenu du fichier log
    def log_content
      Log::get_content
    rescue Exception => e
      "# Impossible d'obtenir le contenu du log : #{e.message}"
    end

    # = main =
    #
    # Méthode principale pour envoyer le rapport à l'administrateur
    # Noter qu'il s'agit bien là de l'envoi du mail
    def send_rapport
      site.send_mail(
        to:       site.mail,
        from:     site.mail,
        subject:  "Rapport administration du #{NOW.as_human_date(true, true, ' ')}",
        message:  path_rapport_admin.read
      )
    rescue Exception => e
      safed_log "    # Impossible d'envoyer le rapport administration : #{e.message}"
      safed_log e.backtrace.join("\n")
      false
    else
      true
    end

    # Initialisation du rapport administration
    # Cette méthode est appelée au début du cron pour checker les
    # programmes.
    def init
      @rapport_administration = String::new
      return self # pour le chainage
    end

    def bind; binding() end

    # Path au mail (vue ERB) contenant le code pour le mail
    # à utiliser pour le rapport
    def path_mail_erb
      @path_mail ||= SuperFile::new([Log::folder, "rapport_admin.erb"])
    end

    # Path du fichier qui contient l'enregistrement des
    # rapports effectués toutes les heures
    def path_rapport_admin
      @path_rapport_admin ||= SuperFile::new([Log::folder, 'rapport_admin.html'])
    end

  end
end #/Unan

safed_log "<- #{__FILE__}"
