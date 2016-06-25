# encoding: UTF-8
=begin
Extension de la class User pour le CRON
=end
class User

  # Mettre à true pour qu'un rapport quotidien d'état
  # sur le programme UN AN UN SCRIPT soit aussi envoyé
  # à l'administration
  UNAN_DAILY_REPORT_FOR_ADMIN = true

class << self

  def log mess
    safed_log mess
  end

  # Méthode principale appelée toutes les heures par le cron job
  # pour voir s'il faut passer un programme au jour suivant.
  #
  # Si c'est le cas, et que l'auteur veut recevoir un rapport
  # quotidien, on construit son rapport et on lui envoie.
  #
  # Rappel : Maintenant, c'est la classe User::CurrentPDay qui
  # fait ce rapport et construit le mail. Noter qu'elle est
  # chargée automatiquement à partir du moment où on utilise :
  #   <user>.current_pday[...]
  # Noter que ce `current_pday` n'a rien à voir avoir la même
  # propriété de <user>.program qui ne fait que retourner le
  # jour-programme courant.
  #
  def traite_users_unanunscript
    log "-> traite_users_unanunscript"
    # RAPPEL : CETTE MÉTHODE EST APPELÉE TOUTES LES HEURES

    site.require_objet 'unan'

    # Boucle sur toutes les auteurs suivant le programme
    drequest = {
      where:    'options LIKE "1%"'
    }
    Unan.table_programs.select(drequest).each do |hprog|
      traite_program_unanunscript hprog
    end
    log "<- traite_users_unanunscript"
  end

  def traite_program_unanunscript hprog
    auteur_id   = hprog[:auteur_id]
    pday        = hprog[:current_pday]
    pday_start  = hprog[:current_pday_start]
    rythme      = hprog[:rythme]
    log "  * Traitement du programme ##{hprog[:id]} de l'auteur ##{auteur_id}"

    # On prend l'auteur
    auteur = User.new(auteur_id)
    log "    Auteur : #{auteur.pseudo} (##{auteur.id})"

    # Calcul du début du prochain jour
    next_pday_start = (pday_start + 1.day.to_f * (5.0 / rythme)).to_i
    log "  = next_pday_start : #{next_pday_start}" +
      "\n                NOW : #{NOW}" +
      "\n             Rythme : #{rythme} "
    if NOW < next_pday_start
      log "Devra être envoyé dans #{(next_pday_start - NOW).as_duree}"
      # begin
      #   site.send_mail_to_admin(
      #     subject:  "UNAN - Rapport (qui serait) envoyé à #{auteur.pseudo}",
      #     message: auteur.current_pday.rapport_complet,
      #     formated: true
      #   )
      # rescue Exception => e
      #   log "### Impossible d'envoyer le rapport à l'administrateur : #{e.message}"
      #   log e.backtrace.join("\n")
      # end
    end

    # Conditions pour que le programme soit passé au jour suivant:
    # 1. Il faut que l'on ait dépassé la date du début du jour-suivant
    # Noter que lorsque ça se produit, puisque le début du jour-programme
    # sera modifié, la valeur de next_pday_start sera poussée au lendemain
    # et donc il faudra attendre que le temps arrive à nouveau à cette
    # valeur pour ré-envoyer le rapport.
    #
    if NOW > next_pday_start
      log "  --- Changement de jour"
      # On produit le changement de jour
      Unan::Program.new(hprog[:id]).current_pday= pday + 1

      # Si l'auteur ne veut pas être prévenu quotidiennement,
      # on ne doit envoyer un rapport que si ses préférences
      # le détermine. Noter que par défaut, c'est un mail quotidien,
      # il faut donc s'assurer que la préférence existe et la
      # régler si ça n'est pas le cas.
      if daily_report_must_be_send_to auteur
        log "  *** Envoi du mail quotidien nécessaire ***"

        # On lui envoie le rapport de changement de jour-programme
        # TODO : POUR LE MOMENT, COMME ÇA NE FONCTIONNE PAS
        # ENCORE TRÈS BIEN, JE N'ENVOIE PAS LE RAPPORT, MAIS J'EN
        # FAIS UNE COPIE À L'ADMINISTRATEUR.
        auteur.current_pday.send_rapport_quotidien

        if UNAN_DAILY_REPORT_FOR_ADMIN
          # On envoie aussi le rapport à l'administrateur
          site.send_mail_to_admin(
            subject:  "UNAN - Rapport envoyé à #{auteur.pseudo}",
            message: auteur.current_pday.rapport_complet,
            formated: true
          )
        end
        # On ajoute ça au safed_log
        log "Auteur ##{auteur.id} (#{auteur.pseudo}) passé au jour-programme #{pday+1} avec succès."
        return true # pour simplifier les tests
      else
        log "   = Pas d'envoi de rapport quotidien (préférences)"
      end
    else
      log "   = Pas d'envoi nécessaire."
      return false # pour simplifier les tests
    end
  rescue Exception => e
    debug e
    error_log "Impossible d'envoyer le rapport : #{e.message} (consulter le débug)"
    return nil
  end

  def daily_report_must_be_send_to auteur
    need_daily_report = auteur.preference(:pref_daily_summary)
    # Valeur par défaut
    if need_daily_report === nil
      auteur.set_preference( :pref_need_daily_report => true )
      need_daily_report = true
    end
    return true if need_daily_report
    # Si l'auteur ne veut pas recevoir de mail quotidien, on
    # ne lui envoie que s'il a des nouveaux travaux ou des
    # dépassements.
    cp = auteur.current_pday
    nombre_ofday    = cp.aworks_ofday.count
    nombre_overrun  = cp.uworks_overrun.count
    alerte =  nombre_ofday > 0 || nombre_overrun > 0
    if alerte
      mess = "   L'auteur ne veut pas recevoir de mail quotidien mais "
      raisons = []
      raisons << 'il est en dépassement d’échéance' if nombre_overrun > 0
      raisons << 'il a de nouveaux travaux'         if nombre_ofday > 0
      mess += raisons.pretty_join
      log mess
    end
    return alerte
  end

end # << self
end #/User
