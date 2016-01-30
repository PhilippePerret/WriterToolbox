# encoding: UTF-8
=begin

Méthodes utiles pour le forum pour tenir informé des nouveaux
messages

Rappel : On doit regarder les nouveaux messages déposés (table_posts)
dans l'heure précédente et alerter les suiveurs des sujets concernés.
Sauf si ces suiveurs n'ont pas visité le sujet depuis la dernière
alerte.

Rappel : la table sujets_followers contient en même temps la liste
des suiveurs d'un sujet et les derniers appels.

  Nouveau message (date > now moins une heure)
  => On récupère les abonnements du sujet concerné (sujet_id)
      C'est une liste d'IDs de users (liste de user_id)
  => On teste si la donnée sujet_id + user_id existe dans la table
  Si c'est le cas, ça signifie que l'user n'a pas visité le sujet
  depuis la dernière alerte qui lui a été envoyée pour le dernier
  message
=end
# On peut charger le fichier database.db qui définit toutes les
# table du forum
require './objet/forum/lib/required/database.rb'

class Forum
class << self


  # = main =
  #
  # Méthode principale de check des nouveaux messages éventuels
  # @usage : Forum::check_new_messages
  def check_new_messages

    # On récupère tous les messages qui ont été créés depuis le
    # dernier checkup du forum et qui sont validés.
    drequest = {where:"created_at > #{last_time_checkup} AND options LIKE '0%'"}
    drequest.merge!( colonnes: [:sujet_id] )
    new_messages = table_posts.select(drequest).values

    # On actualise tout de suite la date de dernier checkup pour
    # pouvoir traiter au prochain tour tous les messages qui auront
    # été créés pendant le processus courant.
    update_last_time_checkup

    # On traite chaque nouveau message du forum en envoyant une alerte
    # aux abonnés du sujets, sauf si une alerte leur a déjà été envoyée
    new_messages.each do |dmessage|

      # TODO Récupérer la liste des abonnés

      # TODO S'en retourner sans rien faire si la liste est nil ou vide

      # TODO Vérifier si l'abonné a déjà reçu une alerte pour un message
      # précédent dans le même sujet (s'en retourner si oui)

      # TODO Envoyer le mail à l'abonné

      # TODO Enregistrer que l'abonné a reçu une alerte pour ce message
      # dans ce sujet
    end

  rescue Exception => e
    add_error "# Impossible de checker les nouveaux messages forum…", e
  end

  # Time de dernier checkup (n'est jamais nil car on met toujours au
  # moins le time d'il y a une heure)
  def last_time_checkup
    @last_time_checkup ||= site.get_last_date(:last_checkup_messages_forum, Time.now.to_i - 3600)
  end
  def update_last_time_checkup
    site.set_last_date(:last_checkup_messages_forum)
  end

  private

    # +err+ Une instance d'erreur
    def add_error message, err
      @errors ||= Array::new
      @errors << {mess:message, error:err}
    end

end #/ << self
end #/Forum
