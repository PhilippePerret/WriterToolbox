# encoding: UTF-8
=begin

Résumé :

    sujet_id          user_id           items_ids

      DÉFINI            ---             Abonnés - Liste IDs users

       ---             DÉFINI           Abonnements - Liste IDs sujets

      DÉFINI           DÉFINI           Date dernière alerte à user_id
                                        pour le sujet sujet_id.


Table contenant 3 CHOSES DISTINCTES en même temps :
  - les informations des suiveurs par sujet
    sujet_id => liste des IDs des Users
    Reconnue par : sujet_id défini, user_id NULL
  - les informations des sujets suivis par user
    user_id => liste des IDs de sujets suivis
    Reconnue par : user_id défini, sujet_id NULL
  - Les informations de notification par sujet
    Reconnue par : user_id défini, sujet_id défini

  On pourrait ajouter qu'en plus, items_ids est une liste pour les
  deux premiers cas et un nombre pour le dernier

  C'est la méthode `<sujet>.add_follower` qui permet d'ajouter
  un follower.
  C'est la méthode `<sujet>.remove_follower` qui permet de supprimer
  un follower
=end
def schema_table_forum_sujets_followers
  @schema_table_forum_sujets_followers ||= {

    # Soit l'ID du sujet (pour définir la liste des followers) soit
    # l'ID de l'user (pour définir la liste des sujets qu'il suit)
    # Donc c'est SOIT L'UNE SOIT L'AUTRE, mais jamais les deux en
    # même temps.
    sujet_id:   {type:"INTEGER"},
    user_id:    {type:"INTEGER"},

    # Liste des IDentifiants d'items OU timestamp de blocage de mail
    # ------------------------------
    # SI user_id est défini, c'est une liste d'ID de sujets (sujets followed)
    # SI sujet_id est défini, c'est une liste d'ID d'users (followers)
    # SI user_id et sujet_id est défini, c'est la date de dernière alerte
    # de nouveau message. Tant que l'user n'est pas revenu sur le sujet
    # aucune autre alerte ne lui est envoyée.
    items_ids:   {type:"BLOB"}
  }
end
