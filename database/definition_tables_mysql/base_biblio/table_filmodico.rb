# encoding: UTF-8
=begin
Schéma de la table des films Filmodico

Note : C'est la même que pour l'atelier Icare, il n'est pas à confondre avec
la table analyse.films qui correspond à cette table au niveau des ID mais
contient moins de renseignements (pour l'analyse).

=end
def schema_table_filmodico
  <<-MYSQL
CREATE TABLE filmodico
  (
    id INTEGER AUTO_INCREMENT,

    # FILM_ID
    # -------
    # Nom symbolique, utilisé par exemple pour les noms de
    # fichiers, pour qu'ils soient plus parlant et simples
    # que l'identifiant string.
    film_id VARCHAR(100) NOT NULL,

    #  TITRE
    # -------
    # Le titre original du film. Noter qu'on utilise `BLOB`
    # ici pour traiter les caractères particulier qui, avec
    # VARCHAR, ne passerait pas (comme dans le titre du
    # film asiatique : Wò Hǔ Cáng Lóng)
    titre     BLOB  NOT NULL,
    
    titre_fr  VARCHAR(255),
    annee     INTEGER(4)    NOT NULL,
    resume    TEXT          NOT NULL,

    #  PAYS
    # ------
    # Liste de pays, en version string, chaque pays est représenté
    # par ses deux lettres et séparés par une espace.
    pays      VARCHAR(30),

    #  DUREE
    # -------
    # La durée du film en secondes. Cette durée est calculée
    # générique compris.
    duree INTEGER(6) NOT NULL,

    duree_generique INTEGER(4),

    # LES PEOPLE DU FILM
    # ------------------
    # Chaque propriété est une liste JSON qui contient des
    # Hash pour chaque people.
    producteurs BLOB,
    realisateur BLOB,
    auteurs     BLOB,
    acteurs     BLOB,
    musique     BLOB,

    #  LINKS
    # -------
    # Les liens qui peuvent renvoyer à des pages narrations,
    # des analyses, etc.
    # Pour le moment cette propriété n'est pas utilisée.
    links BLOB,

    PRIMARY KEY (id)
  );
  MYSQL
end
