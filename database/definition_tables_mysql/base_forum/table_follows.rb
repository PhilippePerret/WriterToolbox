# encoding: UTF-8
=begin

Résumé :

    sujet_id        user_id     items            time

      DÉFINI          ---       Abonnés
                                Liste des users

       ---           DÉFINI     Liste des sujets
                                suivis par user_id

      DÉFINI         DÉFINI     NULL                Date dernière alerte à
                                                    user_id pour le sujet sujet_id.


Table contenant 3 CHOSES DISTINCTES en même temps :
  - les informations des suiveurs par sujet
    sujet_id => liste des IDs des Users
    Reconnue par : sujet_id défini, user_id NULL
  - les informations des sujets suivis par user
    user_id => liste des IDs de sujets suivis
    Reconnue par : user_id défini, sujet_id NULL
  - Les informations de notification par sujet
    Reconnue par : user_id défini, sujet_id défini

  C'est la méthode `<sujet>.add_follower` qui permet d'ajouter
  un follower.
  C'est la méthode `<sujet>.remove_follower` qui permet de supprimer
  un follower
=end
def schema_table_follows
  <<-MYSQL
CREATE TABLE follows
  (

    user_id     INTEGER,
    sujet_id    INTEGER,
    items       BLOB,
    time        INTEGER(10),

    INDEX idx_user  (user_id),
    INDEX idx_sujet (sujet_id)
  );
  MYSQL
end
