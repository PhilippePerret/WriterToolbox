# encoding: UTF-8
=begin

Schéma de la table 'pages_cours' qui consigne toutes les
informations sur les pages utilisées pour le programme UN AN UN SCRIPT
et sert notamment à gérer les handlers de page

=end
def schema_table_pages_cours
  <<-MYSQL
CREATE TABLE pages_cours
  (
    #  ID
    # ----
    # Identifiant unique d'une `page_cours` du programme.
    # Noter que ça n'a RIEN À VOIR avec l'id de la page dans
    # la collection narration.
    # Car une page de cours peut être liée à une page de la
    # collection Narration mais elle peut aussi être indépendante.
    id INTEGER AUTO_INCREMENT,

    #  PATH
    # ------
    # Ce chemin d'accès doit être défini en fonction du type
    # de page de cours. Il peut être nil si c'est une page
    # de la collection Narration. Dans ce cas, il faut fournir
    # la donnée NARRATION_ID.
    path VARCHAR(255),

    # HANDLER
    # -------
    # Pour faire référence à la page
    # NULL si c'est une page qui fait référence à une page
    # de la collection Narration.
    handler VARCHAR(255),

    # TITRE
    # -----
    # Titre de la page de cours, si elle n'est pas liée à
    # une page de la collection Narration
    titre VARCHAR(200),

    # DESCRIPTION
    # -----------
    # Description optionnelle de cette page de cours.
    description TEXT,

    # NARRATION_ID
    # ------------
    # ID de la page dans la collection Narration si
    # cette page de cours est liée à une page de la
    # collection
    narration_id INTEGER,

    #  TYPE
    # ------
    # Pour connaitre la provenance de la page, par exemple une
    # page venant de la collection ou du livre en ligne, ou une
    # page spécialement affectée au programme, etc.
    # C'est ce type qui détermine comment interpréter le path
    # pour savoir où trouver la page
    # U = Programme Un An Un Script
    # N = Collection Narration
    type CHAR(1) NOT NULL,

    # OPTIONS
    # -------
    # Permettent de définir si la page est finie, si elle est
    # affichable, etc.
    options VARCHAR(32),

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
