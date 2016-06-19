# encoding: UTF-8
=begin
Définition du schéma de la table des films
C'est la table minimale contenant les informations minimales
Noter que les ID sont synchronisés avec la table filmodico.films
=end
def schema_table_films_analyses
  <<-MYSQL
CREATE TABLE films_analyses
  (
    id INTEGER AUTO_INCREMENT,

    titre       BLOB NOT NULL,
    titre_fr    VARCHAR(255),
    annee       INTEGER(4),
    created_at  INTEGER(10),
    updated_at  INTEGER(10),


    # FILM_ID
    # --------
    # Un identifiant composé de "<titre><annee>" pour le nommage des
    # dossier, affiche, etc.
    film_id VARCHAR(255) NOT NULL,

    #  SYM
    # -----
    # Utilisé pour que les noms de fichiers soient plus parlant,
    # par exemple.
    sym VARCHAR(100),

    #  OPTIONS
    # ---------
    # Cf. ./objet/analyse/lib/required/film/options.rb
    options VARCHAR(24),

    # REALISATEUR
    # -----------
    # Attention, contrairement aux données dans le filmodico, ces
    # noms sont des strings, pas des Hash avec :nom, :prenom, etc.
    realisateur VARCHAR(255),

    PRIMARY KEY (id)
  );
  MYSQL
end
