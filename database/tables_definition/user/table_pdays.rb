# encoding: UTF-8
=begin

Définition de la table `pdays` qui définit les pdays d'un auteur en
particulier.
Cette table est enregistrée dans la base de données propre à chaque
auteur qui suit le programme, dans la base de données du programme.
=end
def schema_table_user_pdays
  @schema_table_user_pdays ||= {

    # Identifiant unique (mais seulement pour cette table propre
    # à l'auteur)
    # Correspond à l'indice du jour-programme. Donc c'est un
    # nombre de 1 à 365, quel que soit le rythme de travail
    # Contraintement aux autres tables, cet identifiant doit donc
    # être fourni à la création, il n'est pas autoincrémenté
    id: {type:"INTEGER", constraint:"PRIMARY KEY"},

    # ID du programme du p-day
    # ------------------------
    # Juste au cas où, puisque de toute façon la table appartient à une
    # base de données propre au programme.
    program_id: {type:"INTEGER", constraint:"NOT NULL"},

    # Statut
    # ------
    # Pour le moment, juste défini parce que chaque classe doit
    # posséder cette propriété
    status:{type:"INTEGER(1)", constraint:"NOT NULL", default:"0"},

    # Total de points
    # ---------------
    # Le total des points récoltés au cours de ce jour
    points: {type:"INTEGER(3)", constraint:"NOT NULL", default:"0"},

    # Démarrage du p-day
    created_at: {type:"INTEGER(10)", constraint:"NOT NULL"},
    # Date de dernière modification
    updated_at: {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end
