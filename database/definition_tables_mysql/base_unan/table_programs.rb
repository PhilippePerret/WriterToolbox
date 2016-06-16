# encoding: UTF-8
=begin

  Définition de la table pour un programme “Un An Un script”
  Ce sont les données générales
=end
def schema_table_programs
  <<-MYSQL
CREATE TABLE programs
  (
    # ID
    # --
    # Identifiant absolu du programme.
    id INTEGER AUTO_INCREMENT,

    # AUTEUR_ID
    # ---------
    # ID de l'auteur suivant le programme
    auteur_id INTEGER NOT NULL,

    # PROJET_ID
    # ---------
    # Le projet associé au programme. En sachant qu'exceptionnement
    # le projet original pourrait être abandonné au profit d'un
    # nouveau, ce qui explique que programme et projet puissent avoir
    # deux ids
    #
    # Ne pas le mettre "NOT NULL" car il n'est pas défini au
    # moment où le programme est créé
    projet_id INTEGER,

    # RYTHME
    # -------
    # Rythme de travail de l'auteur, de 1 à 9
    # 1 est le plus lent, 9 le plus rapide
    rythme INTEGER(1) DEFAULT 5,

    # CURRENT_PDAY
    # ------------
    # Jour courant du programme, une des données fondamentales
    current_pday INTEGER(3) NOT NULL DEFAULT 1,

    # CURRENT_PDAY_START
    # ------------------
    # Timestamp du démarrage du jour courant
    current_pday_start INTEGER(10) NOT NULL,

    # OPTIONS
    # -------
    # Options du programme.
    # Cf. le fichier ./
    options VARCHAR(32) DEFAULT '000000000000',

    # POINTS
    # ------
    # Nombre de points total marqués jusqu'à ce jour sur
    # le programme
    points INTEGER(8) DEFAULT 0,

    # RETARDS
    # -------
    # Consignes les retards de l'auteur par rapport à ses
    # travaux, pour savoir rapidement s'il est coutumier de
    # ces retards ou s'ils sont exceptionnels.
    # Chaque octet est un jour-programme avec une valeur qui
    # peut aller de 0 (aucun retard) à 8 (trop de gros retards)
    retards VARCHAR(370),

    # CREATED_AT
    # ----------
    # Timestamp de la création du programme
    created_at INTEGER(10),

    # UPDATED_AT
    # ----------
    # Timestamp de la modification de cette donnée
    updated_at INTEGER(10),

    PRIMARY KEY (id)
  )
  MYSQL
end
