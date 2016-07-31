# encoding: UTF-8
=begin

Table des projets

=end
def schema_table_projets
  <<-MYSQL
CREATE TABLE projets
  (
    # ID
    # --
    # IDentifiant du projet, pas forcément le même que l'ID
    # du programme auquel il est associé.
    id  INTEGER AUTO_INCREMENT,

    # TITRE
    # ------
    # Titre du projet
    # Il n'est pas obligatoire et, surtout, il n'est pas encore
    # défini à la création du projet. Par défaut, on met "sans titre"
    titre  VARCHAR(255) DEFAULT 'Sans titre',

    # AUTEUR_ID
    # ---------
    # ID de l'auteur du projet
    auteur_id INTEGER NOT NULL,

    # PROGRAM_ID
    # ----------
    # ID du programme auquel est associé le projet.
    # C'est une valeur non nulle car un projet ne peut pas
    # être dissocié d'un programme ÉCRIRE UN ROMAN/FILM EN UN AN
    program_id INTEGER NOT NULL,

    # RÉSUMÉ
    # ------
    # Le résumé (littéraire) du projet
    resume TEXT,

    # SPECS
    # -----
    # Spécificités du projet, comme le fait que ce soit un
    # roman, etc.
    # Chaque bit représente une spécificité. Cf. le fichier
    # ./objet/unan/lib/required/projet/specs.rb pour le détail.
    specs VARCHAR(32),

    # CREATED_AT
    # ----------
    # Timestamp de la création du projet
    created_at INTEGER(10),

    # UPDATED_AT
    # ----------
    # Timestamp de la modification de cette donnée
    updated_at INTEGER(10),


    PRIMARY KEY (id)
  );
  MYSQL
end
