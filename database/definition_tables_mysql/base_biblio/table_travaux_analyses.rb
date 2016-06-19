# encoding: UTF-8
=begin
Définition du schéma de la table des analystes travaillant sur les
analyses de film.
Cette table permet de savoir qui fait quoi sur quel film.
Noter que les ID sont synchronisés avec la table filmodico.films et la
table analyse.films.
=end
def schema_table_travaux_analyses
  <<-MYSQL
CREATE TABLE travaux_analyses
  (
    id INTEGER AUTO_INCREMENT,
    user_id INTEGER NOT NULL,

    # FILM_ID
    # --------
    # ID du film concerné par ce travail, dans filmodico et
    # dans analyse.films. On peut, grâce à lui, retrouver
    # les informations sur le film.
    # Pour faire une jointure :
    # SELECT *
    #   FROM filmodico
    #   INNER JOIN travaux_analyses
    #   ON filmodico.id = travaux_analyses.film_id;
    film_id INTEGER NOT NULL,

    # TARGET_REF
    # ----------
    # Désignation de l'élément qui est visé par ce travail. Ça peut
    # être un film en général, mais ça peut être également un fichier
    # en particulier.
    #
    # Voir aussi les premiers bits des options qui définissent la
    # cible.
    #
    target_ref VARCHAR(255),

    # OPTIONS
    # -------
    # Options pour cette tache, permet de préciser si elle est
    # achevée, en cours, abandonnée, transférée, etc.
    # Peut-être aussi qu'on sait ce qu'elle est grâce à ça.
    options VARCHAR(32),

    # DESCRIPTION
    # -----------
    # Description littérale de la tache. Sert par exemple pour un
    # affichage dans les tâches en cours.
    description TEXT,

    note        TEXT,
    created_at  INTEGER(10) NOT NULL,
    updated_at  INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  )
  MYSQL
end
