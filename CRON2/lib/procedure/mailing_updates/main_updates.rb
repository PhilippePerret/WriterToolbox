# encoding: UTF-8
#
# Module qui permet d'envoyer les mails des dernières actualisations aux membres 
# inscrits à la boite à outils
#
class CRON2
    def mailing_updates
        Updates.send_mail
    end

    class Updates
        class << self
            def send_mail
                # Pas d'annonce si ça n'est pas l'heure
                Time.now.hour == 0 || return
            end
            # Pas d'annonce si la dernière remonte à moins de 23 heures
            # C'est une protection dans le cas où plusieurs cron seraient appelés
            # dans l'heure, ce qui arrive souvent quand on teste.
            # L'heure est également enregistré dans la table des dernières dates
            site.get_last_date(:mail_updates, 0) < (Time.now - 23*3600).to_i || return

            # Pas d'annonce s'il n'y a rien à annoncer
            no_updates_today = last_updates.empty?
            no_updates_this_week = last_week_updates.empty?
            no_updates_no_samedi = no_updates_today && !samedi?
            samedi_but_no_updates = samedi? && no_updates_this_week)
            (no_updates_no_samedi || samedi_but_no_updates ) && return

            # On indique l'heure du dernier envoi lorsque tout s'est bien passé
            site.set_last_date(:mail_updates)

        end
    end #/CRON2::Updates
end #/CRON2
