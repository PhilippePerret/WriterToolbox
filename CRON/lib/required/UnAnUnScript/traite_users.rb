# encoding: UTF-8
=begin
Extension de la class User pour le CRON
=end
class User
class << self

  def log message
    safed_log message rescue nil
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
  # Je refais entièrement cette méthode.
  def traite_users_unanunscript

    # RAPPEL : CETTE MÉTHODE EST APPELÉE TOUTES LES HEURES

    site.require_objet 'unan'

    # Boucle sur toutes les auteurs suivant le programme
    drequest = {
      where:    'options LIKE "1%"'
    }
    Unan.table_programs.select(drequest).each do |hprog|
      traite_program_unanunscript hprog
    end
  end

  def traite_program_unanunscript hprog
    auteur_id   = hprog[:auteur_id]
    pday        = hprog[:current_pday]
    pday_start  = hprog[:current_pday_start]
    rythme      = hprog[:rythme]

    # Calcul du début du prochain jour
    next_pday_start = (pday_start + 1.day.to_f * (5.0 / rythme)).to_i

    # Conditions pour que le programme soit passé au jour suivant:
    # 1. Il faut que l'on ait dépassé la date du début du jour-suivant
    # Noter que lorsque ça se produit, puisque le début du jour-programme
    # sera modifié, la valeur de next_pday_start sera poussée au lendemain
    # et donc il faudra attendre que le temps arrive à nouveau à cette
    # valeur pour ré-envoyer le rapport.
    #
    if NOW > next_pday_start
      # On produit le changement de jour
      Unan::Program.new(hprog[:id]).current_pday= pday + 1
      # On prend l'auteur
      auteur = User.new(auteur_id)
      # On lui envoie le rapport de changement de jour-programme
      auteur.current_pday.send_rapport_quotidien
      # On ajoute ça au safed_log
      log "Auteur ##{auteur.id} (#{auteur.pseudo}) passé au jour-programme #{pday+1} avec succès."
      return true # pour simplifier les tests
    else
      return false # pour simplifier les tests
    end
  rescue Exception => e
    debug e
    error_log "Impossible d'envoyer le rapport : #{e.message} (consulter le débug)"
    return nil
  end

end # << self
end #/User
