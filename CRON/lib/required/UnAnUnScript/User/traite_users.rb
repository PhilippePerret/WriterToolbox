# encoding: UTF-8
=begin
Extension de la class User pour le CRON
=end
safed_log "-> #{__FILE__}"

class User

  class << self

    # Méthode principale appelée toutes les heures par le cron job
    # pour voir s'il faut passer un programme au jour suivant.
    def traite_users_unanunscript

      # Charger les librairies propres aux Unan::Program pour voir
      # s'il faut passer au jour suivant et passer le programme au
      # jour suivant
      Unan::require_module 'start_pday'

      log "= Nombre d'auteurs en activité : #{users_en_activite.count}"
      log "= IDs : #{users_en_activite.collect{|a| a.id }.pretty_join}\n"

      # Pour initialiser le rapport administration
      Cron::rapport_admin.init

      # Boucler sur tous les programmes en activité
      users_en_activite.each do |auteur|

        log "\n* TRAITEMENT USER EN ACTIVITÉ : #{auteur.pseudo} (##{auteur.id})"

        # On doit mettre l'auteur en user courant pour
        # toutes les méthodes et propriétés qui font
        # usage de `user`
        User::current = auteur

        entete_message = "Le programme ##{auteur.program.id} de #{auteur.pseudo} (##{auteur.id}) "

        log "= User::current : #{auteur.id} (#{auteur.pseudo})"

        # Normalement, ça ne devrait pas être possible, mais apparemment
        # ça arrive
        if auteur.program.nil?
          log "# Bizarrement, l'auteur id:#{auteur.id}/pseudo:#{auteur.pseudo} est considéré comme auteur en activité, mais `auteur.program` retour nil."
          next
        else
          log "= L'ID programme de #{auteur.pseudo} est : ##{auteur.program.id}"
        end

        log "= Jour-programme courant de #{auteur.pseudo} : #{auteur.get_var(:current_pday).inspect}"

        # On regarde si l'auteur a des travaux de plus de deux jours qui
        # n'ont pas encore été démarrés ou marqués vus. Si c'est le cas, il
        # faut leur envoyer une alerte ainsi qu'à l'administrateur.
        # En fait, à l'administrateur, on enregistre le message dans son
        # rapport, dans les alertes importantes
        auteur.program.test_if_works_not_started

        # On teste pour savoir si l'auteur doit passer au jour-programme
        # suivant, en fonction de l'heure et de son rythme d'avancée.
        # Si nécessaire (i.e. s'il y a changement de jour, nouveaux travaux,
        # etc.) cette méthode exécutera tout ce qu'il faut exécuter, avec
        # l'envoi des mails d'annonce, etc.
        resultat = auteur.program.test_if_next_pday
        if resultat != nil
          if resultat[:errors].empty?
            log "--- #{entete_message} a été passé au jour-programme suivant avec succès (P-Day #{auteur.get_var(:current_pday)})."
          else
            log "--- #{entete_message} N'a PAS pu être passé au jour-programme suivant pour les erreurs suivantes : #{resultat[:errors].pretty_join}."
          end
        else
          log "--- #{entete_message} n'a pas eu besoin d'être passé au jour-programme suivant."
        end

        # Si nécessaire, envoyer le mail à l'auteur
        auteur.send_mail_if_needed

      end # / fin de boucle sur tous les auteurs en activité

    end

    # {Array of User} Retourne la liste de tous les auteurs
    # du programme UN AN UN SCRIPT en activité
    def users_en_activite
      @users_en_activite ||= begin
        where_clause = "options LIKE '1%'"
        Unan::table_programs.select(where:where_clause, colonnes:[:auteur_id]).collect do |pid, pdata|
          User::new( pdata[:auteur_id] )
        end.compact
      end
    end
  end # << self
end #/User

safed_log "<- #{__FILE__}"
