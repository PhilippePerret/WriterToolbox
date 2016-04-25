# encoding: UTF-8
=begin

Schéma de la table 'pages_cours' qui consigne toutes les
informations sur les pages utilisées pour le programme UN AN UN SCRIPT
et sert notamment à gérer les handlers de page

=end
def schema_table_unan_cold_pages_cours
  @schema_table_unan_cold_pages_cours ||= {

    # Identifiant unique (mais seulement pour cette table
    id: {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Pointeur
    # --------
    # C'est l'identifiant utilisé pour faire référence à la page
    handler: {type:"VARCHAR(200)", constraint:"NOT NULL"},

    # Titre
    # ------
    titre: {type:"VARCHAR(255)", constraint:"NOT NULL"},

    # Description
    # -----------
    description:{type:"TEXT",constraint:"NOT NULL"},

    # Le chemin d'accès
    # -----------------
    # Ce chemin d'accès doit être défini en fonction du type
    # de page de cours. Il peut être nil si c'est une page
    # de la collection Narration. Dans ce cas, il faut fournir
    # la donnée ci-dessous.
    path:{type:"VARCHAR(255)"},

    # ID de la collection narration
    # -----------------------------
    # Si la page de cours est une page de la collection narration,
    # il faut renseigner cette données
    narration_id:{type:"INTEGER"},

    # Type de la page
    # ---------------
    # Pour connaitre la provenance de la page, par exemple une
    # page venant de la collection ou du livre en ligne, ou une
    # page spécialement affectée au programme, etc.
    # C'est ce type qui détermine comment interpréter le path
    # pour savoir où trouver la page
    type:{type:"VARCHAR(8)", constraint:"NOT NULL"},

    # Options de la page
    # ------------------
    # Permettent de définir si la page est finie, si elle est
    # affichable, etc.
    options: {type:"VARCHAR(32)"},

    created_at:{type:"INTEGER(10)"},
    updated_at:{type:"INTEGER(10)"}
  }
end
