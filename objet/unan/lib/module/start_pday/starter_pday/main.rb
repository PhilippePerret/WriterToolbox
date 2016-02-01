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
  # Méthode qui démarre le programme
  def activer_first_pday
    @next_pday = 1
    proceed_changement_pday
  end

  # = main =
  #
  # Méthode principale qui va passer le programme du jour-programme
  # current_pday au jour-programme next_pday
  def activer_next_pday
    check_validite_program      || raise(ERRORS[:check_validite_program])
    etat_des_lieux_program      || raise(ERRORS[:etat_des_lieux_program])
    proceed_changement_pday     || raise(ERRORS[:proceed_changement_pday])
    send_mail_auteur_if_needed  || raise(ERRORS[:send_mail_auteur_if_needed])
  rescue Exception => e
    log "#ERREUR FATALE : #{e.message}"
  end

  # Vérification de la validité du programme courant
  # Pour l'instant, ça ne fait rien, mais ensuite, on pourra voir
  # s'il faut checker certaines choses pour voir si le programme
  # en lui-même fonctionne bien.
  def check_validite_program
    true
  end


  # Méthode qui procède réellement au changement de jour-programme
  # du programme, qu'il y ait ou non des travaux définis
  def proceed_changement_pday

    # À faire qu'il y ait ou non un jour-programme défini
    # MAIS : En implémentant la méthode, j'obtiens une erreur sur
    # Benoit alors qu'il est clairement au premier jour (l'état des
    # lieux précédent en témoigne) donc je voudrais savoir ce qui
    # foire ici. D'où la raison de tous ces logs avant de procéder
    # au changement proprement dit.

    log "\n\n=== Contrôle dans Unan::Program::StarterPDay::proceed_changement_pday ==="
    log "= Auteur : ##{auteur.id} / #{auteur.pseudo}"
    @reparation_count = 0
    begin
      raise if auteur.get_var(:current_pday).nil?
    rescue Exception => e
      @reparation_count += 0
      if @reparation_count > 1
        raise "Impossible de passer l'auteur ##{auteur.id} (#{auteur.pseudo}) au jour-programme suivant, car son current_pday n'est pas défini dans ses variables et il n'a malheureusement pas pu être réparé."
      else
        # Problème de définition de current_pday…
        # Je dois réparer ce problème pour pouvoir poursuivre. Sur quoi pourrais-je
        # me base pour savoir à quel jour-programme peut en être l'auteur ?
        reparer_error_current_pday_nil
        retry
      end
    end
    log "= Current pday (avec get_var) : #{auteur.get_var(:current_pday).inspect}"
    begin
      thenext_pday = next_pday.freeze
      log "= Next pday calculé avec succès : #{thenext_pday}"
    rescue Exception => e
      log "# Impossible de calculer next_pday : #{e.message} (je le mets à 2 pour pouvoir poursuivre)"
      thenext_pday = 2
    end

    auteur.set_var(current_pday: thenext_pday)
    program.instance_variable_set('@current_pday', thenext_pday)

    return true unless has_new_works?

    # Il ne faut créer le p-day propre au programme et ne faire
    # les procédures suivantes que si ce jour-programme possède
    # un programme, donc des travaux.
    prepare_program_pday

  rescue Exception => e
    log "Erreur fatale dans Unan::Programme::StartPDay::proceed_changement_pday : #{e.message}"
    log "Backtrace :\n" + e.backtrace.join("\n")
    error e.message
  else
    true
  end

  # Tente de réparer la variable :current_pday de l'auteur, quand elle
  # est nil (cela est arrivé au cours des tests avec Benoit, peut-être à
  # cause d'un jour-programme effacé au cours des tests précédents).
  # Pour le moment, on renvoie toujours 1 mais plus tard, on pourra
  # essayer de retrouver ce
  def reparer_error_current_pday_nil
    curpday = 1
    
    auteur.set_var(:current_pday, curpday)
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
    auteur.send_mail

  rescue Exception => e
    error e.message
  else
    true
  end

end #/StarterPDay
end #/Program
end #/Unan
