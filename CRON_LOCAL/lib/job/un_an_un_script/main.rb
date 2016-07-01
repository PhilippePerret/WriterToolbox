# encoding: UTF-8
=begin

  Extension de LocCron traitant en local les auteurs distants du
  programme UN AN UN SCRIPT et les faisant passer au jour suivant
  si c'est nécessaire.

  Extension de la classe DUser pour s'adapter au programme.

=end

# Il faut charger l'objet maintenant car des méthodes ici
# doivent surclasser les méthodes originales (pour pouvoir
# prendre les données distantes et non pas les données
# locales)

class LocCron

  SEND_RAPPORT_TO_ADMIN = true

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
      log "     Prochaine heure d'envoi : #{auteur.next_pday_start.as_human_date(true, true, ' ')} (#{auteur.next_pday_start})", :info
      if auteur.send_unan_report?
        log "     * Le rapport doit être envoyé"
        # On procède à l'envoi du rapport quotidien
        # Noter qu'ici, on le fait vraiment
        force_offline = true
        auteur.current_pday.send_rapport_quotidien(force_offline)
        log "     = Longueur rapport :\n#{auteur.current_pday.rapport_complet}"
        # Envoi du rapport à l'administrateur (pour vérification)
        sent_rapport_unan_to_admin auteur if SEND_RAPPORT_TO_ADMIN
      else
        log "     = Pas de rapport"
      end
    end # /fin de boucle sur tous les auteurs
    log "  = /fin traitement du programme UN AN UN SCRIPT"
  end

  # Envoi le rapport de +auteur+ à l'administrateur
  # si nécessaire
  def sent_rapport_unan_to_admin auteur
    site.send_mail_to_admin(
      subject:            "BOA UN AN UN SCRIPT Rapport envoyé à #{auteur.pseudo}",
      no_header_subject:  true,
      message:            auteur.current_pday.rapport_complet,
      force_offline:      true,
      formated:           true
    )
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
