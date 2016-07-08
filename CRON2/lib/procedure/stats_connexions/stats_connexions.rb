# encoding: UTF-8
#
# Module gérant les connexions qui se sont produites récemment, pour faire un 
# rapport et voir qui se connecte au site et à quelle fréquence.
#

class CRON2

    # Fréquence d'envoi du rapport des connexions
    #
    # Noter qu'avant on prenait la valeur dans le fichier de configuration
    # de façon assez sale. Maintenant, il faut le mettre ici et le régler
    # ici.
    #
    FREQUENCE_RAPPORT_CONNEXIONS = :twice_a_day

    # = main =
    #
    # Méthode principale qui étudie les dernières connexions et fait un
    # rapport pour l'administrateur.
    #
    # La méthode retourne NIL si ce n'était pas l'heure de faire le 
    # rapport, retourne FALSE en cas d'erreur ou retourne TRUE quand
    # le rapport s'est fait avec succès.
    #
    def stats_connexions
       rapport_needed? || (return nil)
        log "* Résumé des connexions par IP"
        ireport = ConnexionsReport.new
        ireport.build_report
        if ireport.has_connexions?
            ireport.consigne_report
            ireport.send_report
        end
        ireport.remove_connexions
    rescue Exception => e
        log "Erreur principale dans stats_connexions", e
        false
    else
        true
    end
    def rapport_needed?
        case FREQUENCE_RAPPORT_CONNEXIONS
        when nil
        when :tout_de_suite, :now
            return true
        when :one_an_hour, :une_par_heure
            return true # puisque c'est le cron horaire
        when :twice_a_day, :deux_par_jour
            return premiere_heure || now.hour == 12
        when :one_a_day, :une_page_jour
            # Retourne true si on est dans la première heure du jour
            return premiere_heure
        when :one_a_week, :une_par_semaine
            return now.wday == 1 && premiere_heure
        when :one_a_month, :une_par_mois
            return now.mday == 1 && premiere_heure
        else
            return false
        end
    end

end
