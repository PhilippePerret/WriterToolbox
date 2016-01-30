# encoding: UTF-8
=begin

Table contenant en même temps :
  - les informations des suiveurs par sujet
    sujet_id => liste des IDs des Users
  - les informations des sujets suivis par user
    user_id => liste des IDs de sujets suivis

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

    # Liste des IDentifiants d'items
    # ------------------------------
    # SI user_id est défini, c'est une liste d'ID de sujets (sujets followed)
    # SI sujets_id est défini, c'est une liste d'ID d'users (followers)
    items_ids:   {type:"BLOB"}
  }
end
