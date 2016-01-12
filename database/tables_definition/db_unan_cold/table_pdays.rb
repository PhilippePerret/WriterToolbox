# encoding: UTF-8
=begin

Définition de la table `pdays` qui définit les pdays d'un auteur en
particulier.
Cette table est enregistrée dans la base de données propre à chaque
auteur qui suit le programme.
=end
def schema_table_unan_cold_pdays
  @schema_table_unan_pdays ||= {

    # Identifiant unique (mais seulement pour cette table propre
    # à l'auteur)
    id: {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Index du p-day
    # --------------
    # Index/ID dans la table absolute_pdays qui définit tous les
    # jours-programme.
    pday_id: {type:"INTEGER", constraint:"NOT NULL"},

    # Total de points
    # ---------------
    # Le total des points récoltés au cours de ce jour
    points: {type:"INTEGER(3)", constraint:"NOT NULL", default:"0"}

  }
end
