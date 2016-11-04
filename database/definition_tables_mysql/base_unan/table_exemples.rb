# encoding: UTF-8
=begin
Table 'exemples' permettant d'enregistrer des exemples de
résultats pour chaque travail, exemples tirés ou
inspirés de films ou totalement invnentés.

Permet d'alimenter la propriété `exemples` des étapes absolues
=end
def schema_table_exemples
  <<-MYSQL
CREATE TABLE exemples
  (
    id INTEGER AUTO_INCREMENT,

    #  TITRE
    # -------
    # Doit être assez cours, simplement pour affichage dans un
    # listing. Ça peut être "Fondamentales de Babe" ou
    # "Synopsis de Titanic" (ne pas utiliser "Exemple" qui sera
    # ajouté)
    titre VARCHAR(255) NOT NULL,

    #  CONTENT
    # ---------
    # Le contenu proprement dit de l'exemple, donc
    # l'exemple lui-même. Peut contenir simplement un texte introductif
    # à une page d'analyse de film.
    content TEXT NOT NULL,

    #  WORK_ID
    # ---------
    # ID du travail (absolute_work) auquel est associé cet exemple
    # (Mais est-ce que ça sert vraiment, entendu qu'un exemple pourrait
    # servir à plusieurs travaux absolus différents)
    work_id INTEGER,

    #  NOTES
    # -------
    # Notes optionnelles qui seront données à l'auteur à propos de
    # l'exemple fourni.
    notes TEXT,

    #  SOURCE
    # --------
    # La source de l'exemple, expliqué de façon littéraire, mais
    # pas trop longue. Pour expliquer si ça vient d'un livre,
    # d'un exemple personnel, des analyses, etc.
    source VARCHAR(1000),

    # SOURCE_TYPE
    # -----------------
    # Suite de bits définissant le type de la source
    # BIT 1 : 0:indéfini, 1:perso, 2:film, 3:série, etc.
    # (cf. TYPE_SOURCE dans ./objet/unan_admin/lib/module/exemple/constants.rb)
    # BIT 2-5 : Année de la source
    # BIT 6-7 : Pays de la source ("fr" = français, "us" = USA, etc.)
    source_type VARCHAR(16) DEFAULT '0000000',

    # UPDATED_AT
    # ----------
    updated_at INTEGER(10),

    # CREATED_AT
    # ----------
    # Date de création de la donnée
    created_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
