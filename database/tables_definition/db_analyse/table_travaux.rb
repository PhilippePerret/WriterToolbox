# encoding: UTF-8
=begin
Définition du schéma de la table des analystes travaillant sur les
analyses de film.
Cette table permet de savoir qui fait quoi sur quel film.
Noter que les ID sont synchronisés avec la table filmodico.films et la
table analyse.films.
=end
def schema_table_analyse_travaux
  @schema_table_analyse_travaux ||= {

    # ID du travail.
    id:   {type:"INTEGER",       constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Auteur ID
    # ---------
    # ID dans la table user de l'analyste qui exécute ce travail
    user_id:      {type:"INTEGER", constraint:"NOT NULL"},

    # Film ID
    # --------
    # ID du film concerné par ce travail, dans filmodico et
    # dans analyse.films. On peut, grâce à lui, retrouver
    # les informations sur le film.
    # Pour faire une jointure :
    # SELECT *
    #   FROM films
    #   INNER JOIN travaux
    #   ON films.id = travaux.film_id;
    film_id:      {type:"INTEGER", constraint:"NOT NULL"},

    # Cible
    # -----
    # Désignation de l'élément qui est visé par ce travail. Ça peut
    # être un film en général, mais ça peut être également un fichier
    # en particulier.
    target_ref:   {type:"VARCHAR(255)"},

    # Type de la cible
    # ----------------
    # Permet de préciser si la cible est le film lui-même, ou un
    # fichier particulier, la collecte, etc.
    target_type:  {type:"VARCHAR(4)"},

    # Options
    # -------
    # Options pour cette tache, permet de préciser si elle est
    # achevée, en cours, abandonnée, transférée, etc.
    # Peut-être aussi qu'on sait ce qu'elle est grâce à ça.
    options:      {type:"VARCHAR(32)"},

    # Description
    # -----------
    # Description littérale de la tache. Sert par exemple pour un
    # affichage dans les tâches en cours.
    description:  {type:"TEXT"},

    # Note
    # ----
    note:         {type:"TEXT"},

    # Dates de cette tache
    # --------------------
    created_at:   {type:"INTEGER(10)", constraint:"NOT NULL"},
    updated_at:   {type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end
