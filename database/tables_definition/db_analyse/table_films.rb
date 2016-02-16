# encoding: UTF-8
=begin
Définition du schéma de la table des films
C'est la table minimale contenant les informations minimales
Noter que les ID sont synchronisés avec la table filmodico.films
=end
def schema_table_analyse_films
  @schema_table_analyse_films ||= {
    id:   {type:"INTEGER",       constraint:"PRIMARY KEY AUTOINCREMENT"},
    # Nom symbolique
    # --------------
    # Utilisé pour que les noms de fichiers soient plus parlant,
    # par exemple.
    sym:          {type:'VARCHAR(100)', constraint:"NOT NULL"},
    # Titre à utiliser pour l'affichage
    titre:        {type:"VARCHAR(255)", constraint:"NOT NULL"},
    titre_fr:     {type:"VARCHAR(255)"},
    # Options
    # -------
    # Cf. ./objet/analyse/lib/required/film/options.rb
    options:      {type:"VARCHAR(24)"},
    realisateur:  {type:"VARCHAR(255)"},
    auteurs:      {type:"VARCHAR(255)"},
    annee:        {type:"INTEGER(4)"},
    pays:         {type:"VARCHAR(2)"},
    created_at:   {type:"INTEGER(10)", constraint:"NOT NULL"},
    updated_at:   {type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end
