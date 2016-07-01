# encoding: UTF-8
=begin

  Extension de LocCron traitant en local les auteurs distants du
  programme UN AN UN SCRIPT et les faisant passer au jour suivant
  si c'est nécessaire.

  Extension de la classe DUser pour s'adapter au programme.

=end
class LocCron

  # Méthode principale qui s'occupe du programme
  # UN AN UN SCRIPT.
  #
  # Il s'assure notamment de faire passer les auteurs
  # qui le doivent au jour suivant.
  def un_an_un_script
    log "* Traitement du programme UN AN UN SCRIPT"

    # Boucle sur les auteurs.
    # +auteur+ est une instance DUser de l'auteur, donc
    # avec les données distantes.
    auteurs.each do |auteur|
      log "  ** Traitement auteur #{auteur.pseudo}"
      log "     Prochaine heure d'envoi : #{auteur.next_pday_start.as_human_date(true, true, ' ')} (#{next_pday_start})", :info
      if auteur.send_unan_report?
        log "     * Rapport doit être envoyé"

      else
        # S'il n'est pas encore temps d'envoyer le rapport ou
        # que ça n'est pas nécessaire, on ne fait rien
        log "     = Pas de rapport"
      end
    end # /fin de boucle sur tous les auteurs
    log "  = /fin traitement du programme UN AN UN SCRIPT"
  end


  # Retourne un Array d'instances DUser de tous les auteurs qui
  # sont en train de suivre le programme UN AN UN SCRIPT
  #
  # Noter qu'il s'agit ici des données réelles, sur le site
  # 
  def auteurs
    @auteurs ||= begin
      drequest = {where: 'options LIKE "1%"'}
      table_programs.select(drequest).collect do |huser|
        DUser.new( huser[:auteur_id], huser.merge( prefix: 'program' ) )
      end
    end
  end

  def table_programs
    @table_programs ||= site.dbm_table(:unan, 'programs', online = true)
  end
end #/LocCron


class DUser

  # RETURN true si on doit envoyer le rapport à l'auteur
  # On doit l'envoyer si :
  #   - l'auteur veut recevoir ses rapports quotidien
  #   OU - il a de nouveaux travaux ou des travaux en retard
  #   - l'heure de l'envoi est arrivée.
  def send_unan_report?
    time_to_send_unan_report? && ( want_daily_mail? || has_new_or_overrun_work? )
  end

  # ---------------------------------------------------------------------
  # Retourne l'heure du prochain envoi
  def next_pday_start
    @next_pday_start ||= begin
      # Pour raccourcir le nom des variables
      pday        = program_current_pday
      pday_start  = program_current_pday_start
      rythme      = program_rythme

      # Si l'auteur veut recevoir son mail à heure fixe et qu'il
      # est bien en rythme 5, il faut vérifier que l'heure de son
      # prochain envoi correspond bien à l'heure qu'il a choisi.
      # Dans le cas contraire, il faut modifier l'heure de son
      # prochain envoi. Noter que ça peut intervenir à n'importe
      # quelle heure.
      begin
        if fixed_time_mail
          if rythme == 5
            heure_choisie = heure_envoi_rapport
            jour_start    = Time.at(pday_start)
            heure_start   = jour_start.hour
            if heure_start != heure_choisie
              # L'heure choisie ne correspond pas à l'heure de
              # démarrage du jour-programme courant. On modifie
              # cette heure pour que ça corresponde. C'est-à-dire
              # qu'on prend le jour de démarrage en référence,
              # et qu'on règle le pday_start à l'heure choisie
              heure_good = Time.new(jour_start.year, jour_start.month, jour_start.day, heure_choisie, 0, 0)
              pday_start = heure_good.to_i
              locron.table_programs.set(program_id, { current_pday_start: pday_start } )
            end
          else
            # Ça n'a pas de sens pour un rythme qui ne correspond
            # pas à : 1 jour-programme = 1 jour réel
          end
        end
      rescue Exception => e
        log "Impossible de mettre l'heure d'envoi du rapport quotidien à l'heure choisie (#{heure_choisie})…", e
      end

      # Calcul du début du prochain jour
      (pday_start + 1.day.to_f * (5.0 / rythme)).to_i
    end
  end
  # ---------------------------------------------------------------------

  # RETURN true s'il eest l'heure pour l'auteur de recevoir
  # son rapport quotidien
  def time_to_send_unan_report?
    return NOW > next_pday_start
  end
  # RETURN true si l'auteur veut recevoir son rapport
  # quotidiennement.
  def want_daily_mail?
    pds = preference(:pref_daily_summary)
    pds = true if pds === nil
    pds
  end

  # RETURN true si l'auteur a des nouveaux travaux ou
  # des travaux en dépassement
  def has_new_or_overrun_work?
    false
  end

  # RETURN l'heure à laquelle l'auteur veut peut-être qu'on
  # lui envoie son rapport.
  def heure_envoi_rapport
    @heure_envoi_rapport ||= preference(:dayly_mail_hour).to_i
  end

  # True si le temps du mail est fixé, false dans le cas
  # contraire
  def fixed_time_mail
    @fixed_time_mail ||= !!preference(:fixed_time_mail)
  end

end
