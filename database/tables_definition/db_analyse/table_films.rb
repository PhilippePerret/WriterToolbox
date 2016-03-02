# encoding: UTF-8
=begin
Définition du schéma de la table des films
C'est la table minimale contenant les informations minimales
Noter que les ID sont synchronisés avec la table filmodico.films
=end
def schema_table_analyse_films
  @schema_table_analyse_films ||= {
    id:   {type:"INTEGER",       constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Titres du film, original et français if any
    # --------------
    titre:        {type:"VARCHAR(255)", constraint:"NOT NULL"},
    titre_fr:     {type:"VARCHAR(255)"},

    # Film ID
    # --------
    # Un identifiant composé de "<titre><annee>" pour le nommage des
    # dossier, etc. Utilisé dans les anciennes analyses
    film_id:      {type:"VARCHAR(255)", constraint:"NOT NULL"},

    # Nom symbolique
    # --------------
    # Utilisé pour que les noms de fichiers soient plus parlant,
    # par exemple.
    sym:          {type:'VARCHAR(100)', constraint:"NOT NULL"},

    # Options
    # -------
    # Cf. ./objet/analyse/lib/required/film/options.rb
    options:      {type:"VARCHAR(24)"},

    # People
    # ------
    # Attention, contrairement aux données dans le filmodico, ces
    # noms sont des strings, pas des Hash avec :nom, :prenom, etc.
    realisateur:  {type:"VARCHAR(255)"},
    
    annee:        {type:"INTEGER(4)"},
    created_at:   {type:"INTEGER(10)", constraint:"NOT NULL"},
    updated_at:   {type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end
