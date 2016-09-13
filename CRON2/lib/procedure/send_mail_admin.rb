# encoding: UTF-8
#
# Envoi du mail final à l'administrateur, s'il le faut vraiment.

class CRON2


    SEND_REPORT_TO_ADMIN = false

    # La méthode principale qui envoie le mail final à l'administrateur
    # si c'est nécessaire, c'est-à-dire si la constante SEND_MAIL est à
    # true et/ou qu'il s'est produit des erreurs au cours du cron
    def send_mail_admin
        # TODO Il faudra voir comment se définit ce nombre d'erreurs en
        # sachant que s'il est ici, c'est bon, c'est une variable de
        # l'instance singleton de CRON2 qui pourra être affectée par
        # tous les autres processus.
       @nombre_erreurs ||= 0
        # En fait il faut envoyer le rapport seulement si la constante
        # le demande et/ou s'il y a des erreurs. Donc si le nombre d
        # 'erreurs est nil et qu'il ne faut pas envoyer le rapport,
        # alors on peut s'en retourner illico.
        return nil if !SEND_REPORT_TO_ADMIN && @nombre_erreurs == 0
        # Initialisation du rapport administrateur
        areport = String.new
        if File.exist?(logerrorfile)
            mess =
                if @nombre_erreurs > 1
                    "#{@nombre_erreurs} erreurs se sont produites"
                else
                    'Une erreur s’est produite'
                end
            areport << "<strong class='warning' style='display:block;margin:2em;border:1px solid red;font-size:13pt'>#{mess} au cours du dernier cron LOCAL…</strong>\n"
            areport << File.open(logerrorfile,'r'){|f| f.read.force_encoding('utf-8')}
        end

        # On ajoute toujours le rapport normal s'il faut un rapport
        # complet. Sinon, on indique juste un message simple
        if File.exist?(logfile)
            areport << File.open(logfile,'r'){|f| f.read.force_encoding('utf-8')}
        end

        if areport.nil_if_empty.nil?
          # On signale le problème mais on envoie quand même le mail
          # pour signaler la chose.
          areport = "Bizarrement, il n'y a aucun texte à reporter."
        end

        # On transforme les retours chariot en DIV et on définit la
        # taille de la police.
        areport = areport.
            split("\n").
            collect{|p|"<div>#{p}</div>"}.join('').
            in_div(style: 'font-size: 12pt')

        # On envoie le rapport
        site.send_mail_to_admin(
            subject:        "RAPPORT CRON #{NOW.as_human_date(true, true, ' ')}",
            message:        areport,
            formated:       true,
            force_offline:  true,
            no_header:      true
        )

        # Si tout s'est bien passé, on peut détruire les fichiers logs
        detruire_fichiers_logs


    end #/send_mail_admin

    # Destruction des fichiers logs
    #
    # Notes :
    #   - la méthode ne sera appelée que si tout s'est bien passé
    #   - les fichiers seront quand même reconstruits (peut-être) si d'autres
    #     messages sont ajoutés ensuite. Mais ils feront partie du prochain
    #     log
    #
    def detruire_fichiers_logs
        File.unlink logfile if File.exist? logfile
        File.unlink logerrorfile if File.exist? logerrorfile
    end
    def logfile
        @logfile ||= CRON2::Log.logpath
    end
    def logerrorfile
        @logerrorfile ||= CRON2::Log.logerrorpath
    end
end
