# encoding: UTF-8
=begin
Schéma de la table des films Filmodico

Note : C'est la même que pour l'atelier Icare, il n'est pas à confondre avec
la table analyse.films qui correspond à cette table au niveau des ID mais
contient moins de renseignements.

=end
def schema_table_filmodico_films
  @schema_table_filmodico_films ||= begin
    id:   {type:"INTEGER",       constraint:"PRIMARY KEY AUTOINCREMENT"},
    # Nom symbolique
    # --------------
    # Utilisé pour que les noms de fichiers soient plus parlant,
    # par exemple.
    film_id:      {type:'VARCHAR(100)', constraint:"NOT NULL"},
    # Titre à utiliser pour l'affichage
    titre:        {type:"VARCHAR(255)", constraint:"NOT NULL"},
    titre_fr:     {type:"VARCHAR(255)"},
    pays:         {type:"BLOB"}, # Array de pays
    annee:        {type:"INTEGER(4)"},
    duree:        {type:"INTEGER"},
    duree_generique:  {type:'INTEGER'},
    resume:       {type:"TEXT"},
    realisateur:  {type:"BLOB"},
    auteurs:      {type:"BLOB"},
    acteurs:      {type:"BLOB"},
    producteurs:  {type:"BLOB"},
    musique:      {type:"BLOB"},
    links:        {type:"BLOB"},
  end
end
