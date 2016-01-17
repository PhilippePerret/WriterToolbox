# encoding: UTF-8
=begin
Extension de la class User pour le CRON
=end
class User

  class << self

    # Méthode principale appelée toutes les heures par le cron job
    def traite_users_unanunscript
      users_en_activite.each do |auteur|

        # On teste pour savoir si l'auteur doit passer au jour-programme
        # suivant, en fonction de l'heure et de son rythme d'avancée.
        # Si nécessaire (i.e. s'il y a changement de jour, nouveaux travaux,
        # etc.) cette méthode exécutera tout ce qu'il faut exécuter, avec
        # l'envoi des mails d'annonce, etc.
        auteur.program.test_if_next_pday

      end
    end

    # {Array of User} Retourne la liste de tous les auteurs
    # du programme UN AN UN SCRIPT en activité
    def users_en_activite
      where_clause = "options LIKE '1%'"
      Unan::table_programs.select(where:where_clause, colonnes:[:auteur_id]).collect do |pid, pdata|
        User::new( pdata[:auteur_id] )
      end
    end
  end # << self
end #/User
