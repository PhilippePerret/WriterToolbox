# encoding: UTF-8
=begin

Class Unan::Program::StarterPDay
--------------------------------
C'est le démarreur de jour-programme

Je tente de le séparer de Unan::Program pour profiter des variables
d'instance et compagnie.
=end
class Unan
class Program
class StarterPDay

  ERRORS = {
    :check_validite_program     => "Impossible de checker la validité du programme…",
    :etat_des_lieux_program     => "Impossible de faire l'état des lieux du programme…",
    :proceed_changement_pday    => "Impossible de procéder au changement de jour programme…",
    :send_mail_auteur_if_needed => "Impossible d'envoyer le mail à l'auteur du programme…"
  }

  # {Array} Les erreurs rencontrées au cours du démarrage
  # Noter que normalement, ces erreurs indiquent que le jour-programme
  # suivant n'a pas pu être démarré.
  attr_reader :errors

  # {Unan::Program} Le programme dont il faut changer le jour-programme
  attr_reader :program

  def initialize program
    @program = program
    # Pour conserver la liste de toutes les erreurs rencontrées et savoir
    # si le jour suivant a pu être démarré avec succès
    @errors  = Array::new
  end

  # ---------------------------------------------------------------------
  #   Méthodes de passage au jour suivant
  # ---------------------------------------------------------------------

  # = main =
  #
  # Méthode qui démarre le programme
  def activer_first_pday
    proceed_changement_pday
  end

  # = main =
  #
  # Méthode principale qui va passer le programme du jour-programme
  # current_pday au jour-programme next_pday
  def activer_next_pday
    check_validite_program        || raise(ERRORS[:check_validite_program])
    auteur.program.etat_des_lieux || raise(ERRORS[:etat_des_lieux_program])
    proceed_changement_pday       || raise(ERRORS[:proceed_changement_pday])
    send_mail_auteur_if_needed    || raise(ERRORS[:send_mail_auteur_if_needed])
  rescue Exception => e
    @errors << "# ERREUR FATALE : #{e.message}"
    log "# ERREUR FATALE : #{e.message}"
    log e.backtrace.join("\n")
  ensure
    return {errors: @errors}
  end

  # Vérification de la validité du programme courant
  # Pour l'instant, ça ne fait rien, mais ensuite, on pourra voir
  # s'il faut checker certaines choses pour voir si le programme
  # en lui-même fonctionne bien.
  def check_validite_program
    true
  end


  # Méthode qui procède réellement au changement de jour-programme
  # du programme, qu'il y ait ou non des travaux définis.
  # Il consiste simplement à :
  #   - définir la donnée `current_pday` du program
  #   - définir la donnée `current_pday_start` du program
  #     (ça se fait automatiquement quand on change le pday
  #      courant dans le programme)
  def proceed_changement_pday

    auteur.program.current_pday= auteur.program.current_pday + 1

  rescue Exception => e
    @errors << e.message
    log "Erreur fatale dans Unan::Programme::StartPDay::proceed_changement_pday : #{e.message}"
    log "Backtrace :\n" + e.backtrace.join("\n")
    error e.message
  else
    true
  end

  # On envoie un mail à l'auteur si nécessaire
  # Cela est nécessaire lorsque :
  #   - un nouveau jour-programme est initié
  #   - l'auteur veut être averti quotidiennement
  def send_mail_auteur_if_needed
    # Pas de mail s'il n'y a pas de jour-programme et si l'auteur
    # ne veut pas être averti quotidiennement
    return true unless has_new_works? || mail_journalier?

    # Sinon, un mail lui est envoyé, qu'on construit à partir
    # des données de `mail_auteur` (qui est une instance qui
    # a permis de constituer les sections du mail — cf. mails.rb)
    mail_auteur.send_mail

  rescue Exception => e
    @errors << e.message
    log "# ERROR DANS send_mail_auteur_if_needed : #{e.message}"
    log "# Backtrace: \n" + e.backtrace.join("\n")
    error e.message
  else
    true
  end

end #/StarterPDay
end #/Program
end #/Unan
