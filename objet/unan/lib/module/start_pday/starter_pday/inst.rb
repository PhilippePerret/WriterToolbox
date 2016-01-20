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

  # {Unan::Program} Le programme dont il faut changer le jour-programme
  attr_reader :program

  def initialize program
    @program = program
  end

  # ---------------------------------------------------------------------
  #   Méthodes de passage (au jour suivant)
  # ---------------------------------------------------------------------

  # = main =
  #
  # Méthode principale qui va passer le programme du jour-programme
  # current_pday au jour-programme next_pday
  def active_next_pday
    check_validite_program      || raise(ERRORS[:check_validite_program])
    etat_des_lieux_program      || raise(ERRORS[:etat_des_lieux_program])
    proceed_changement_pday     || raise(ERRORS[:proceed_changement_pday])
    send_mail_auteur_if_needed  || raise(ERRORS[:send_mail_auteur_if_needed])
  rescue Exception => e
    log "#ERREUR FATALE : #{e.message}"
  end

  # Vérification de la validité du programme courant
  def check_validite_program
    true
  end


  # Méthode qui procède réellement au changement de jour-programme
  # du programme, qu'il y ait ou non des travaux définis
  def proceed_changement_pday
    # À faire qu'il y ait ou non un jour-programme défini
    auteur.set_var(current_pday: next_pday)
    program.instance_variable_set('@current_pday', next_pday)

    return true unless has_new_works?

    # À faire s'il y a un nouveau jour-programme défini

  rescue Exception => e
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
    # Sinon, un mail lui est envoyé
  rescue Exception => e
    error e.message
  else
    true
  end
end #/StarterPDay
end #/Program
end #/Unan
