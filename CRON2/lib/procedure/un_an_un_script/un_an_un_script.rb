# encoding: UTF-8
#
# Module pour le traitement des auteurs qui suivent le programme
# UAUS + quelques petites autres choses sans importance
#
require 'singleton'

class CRON2
  include Singleton

  include MethodesProcedure

  # Mettre à true pour que le rapport journalier qui est envoyé à
  # l'auteur soit également envoyer à l'administrateur. Permet de
  # vérifier que le rapport est correct.
  SEND_RAPPORT_TO_ADMIN = true

  # = main =
  #
  # Méthode principal appelée par le programme principal
  #
  def un_an_un_script

    # On répète l'opération pour chaque auteur du programme
    auteurs.each do |auteur|
      log "Traitement de l'auteur #{auteur.pseudo}"
      log "  - Prochaine heure d'envoi : #{auteur.next_pday_start.as_human_date(true, true, ' ')} (#{auteur.next_pday_start})"
      if auteur.send_unan_report?
        log "  - Il faut envoyer le rapport (<= send_unan_report? true)"
        auteur.current_pday.send_rapport_quotidien
        SEND_RAPPORT_TO_ADMIN && send_rapport_unan_to_admin(auteur)
        CRON2::Histo.add(code: '77201', data: auteur.id)
      end
    end
  end

  # Transmission à l'administrateur du programme de l'auteur
  def send_rapport_unan_to_admin auteur
    site.send_mail_to_admin(
    subject:    "UN AN - Rapport envoyé à #{auteur.pseudo}",
    message:    auteur.current_pday.rapport_complet,
    formated:   true
    )
  rescue Exception => e
    log "Problème en envoyant le rapport d'auteur à l'administrateur", e
  end

  # Retourne la liste (Array) des instances DUser des auteurs qui
  # suivent le programme UAUS
  def auteurs
    @auteurs ||= programmes.collect{|hp| DUser.new(hp[:auteur_id])}
  end

  # Retourne la liste des programmes courant
  def programmes
    @programmes ||= begin
      # Données de la requête pour ne sélectionner que les programmes
      # qui sont en cours.
      where = "options LIKE '1%'"
      table_programs.select(where: where)
    end
  end

  # Table contenant tous les programmes
  def table_programs
    @table_programs ||= Unan.table_programs
  end
end #/CRON2
