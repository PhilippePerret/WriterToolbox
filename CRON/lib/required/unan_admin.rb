# encoding: UTF-8
require 'singleton'

class Unan

  class << self
    def rapport_admin
      @rapport_admin ||= RapportAdmin.instance
    end
  end # << self

  # ---------------------------------------------------------------------
  #   Class pour la gestion du mail administrateur
  # ---------------------------------------------------------------------
  class RapportAdmin

    include Singleton

    # SI true, ne reçoit le rapport qu'une fois par jour
    # Si false, reçoit le rapport toutes les heures
    RAPPORT_ADMIN_ONCE_A_DAY = false

    attr_accessor :rapport_administration
    attr_accessor :depassements

    # = main =
    #
    # Traitement du rapport. Soit on l'envoie, soit on l'enregistre
    # dans un fichier en attendant de l'envoyer en début de journée
    def traite
      # Noter que même si le rapport courant est nil, il faut
      # traiter la méthode, car il est peut-être temps d'envoyer
      # tous les rapports qui ont été consignés dans le fichier
      # au cours de la journée.
      # Sauf, donc, si le rapport est vide et qu'il faut envoyer
      # les rapports au fur et à mesure. Dans ce cas-là uniquement
      # il n'y a rien à faire.
      return if false == RAPPORT_ADMIN_ONCE_A_DAY && rapport_mis_en_forme.empty?

      # On enregistre le rapport mis en forme dans le fichier,
      # s'il existe, car c'est ce fichier qui sera lu et mis
      # dans le mail
      unless rapport_mis_en_forme.empty?
        File.open(path_rapport_admin.to_s, 'a') do |f|
          f.write "\n\n#{rapport_mis_en_forme}"
        end
        log "Rapport administration consigné dans un fichier"
      end

      # S'il faut envoyer le rapport seulement une fois par
      # jour et qu'on est dans la première heure de la journée
      # alors il faut envoyer le rapport.
      if RAPPORT_ADMIN_ONCE_A_DAY && Time.now.hour == 0
        send_rapport
        log "Rapport journalier envoyé à l'administration"
        path_rapport_admin.remove
      else
        # On doit envoyer le rapport toutes les heures
        message_mail = mail_path.deserb( self )
        log "Rapport horaire envoyé à l'administration"
      end
    end

    # {String} Retourn le rapport mis en forme
    def rapport_mis_en_forme
      @rapport_mis_en_forme ||= begin
        c = ""
        c << "<h3>Dépassements</h3>"
        c << depassements.collect{|k, v| v.in_li}.join.in_ul

        unless c.empty?
          # On ajoute un titre général et le dernier log au
          # mail qui sera envoyé
          "<h2>Rapport administration du cronjob du #{NOW.as_human_date(true, true)}</h2>#{c}<hr />#{log_content}"
        else
          nil
        end
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
        subject:  "Rapport administration du #{NOW.as_human_date}",
        message:  path_mail.deserb(self)
      )
    end

    # Initialisation du rapport administration
    # Cette méthode est appelée au début du cron pour checker les
    # programmes.
    def init
      @rapport_administration = String::new
      self.depassements           = Hash::new
      return self # pour le chainage
    end

    def bind; binding() end

    # Path au mail (vue ERB) contenant le code pour le mail
    # à utiliser pour le rapport
    def path_mail
      @path_mail ||= Unan::folder_module + "start_pday/mail/admin_rapport.erb"
    end

    # Path du fichier qui contient l'enregistrement des
    # rapports effectués toutes les heures
    def path_rapport_admin
      @path_rapport_admin ||= SuperFile::new(['.', 'CRON', 'rapport_admin.html'])
    end

  end
end #/Unan
