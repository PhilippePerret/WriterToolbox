# encoding: UTF-8
=begin

Définition de la table pour un programme “Un An Un script”
Ce sont les données générales

=end
def schema_table_unan_programme
  @schema_table_unan_programme ||= {
    id:           {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},
    auteur_id:    {type:"INTEGER", constraint:"NOT NULL"},
    # Options
    # -------
    # Pour la définition de chaque bit des options, cf. le
    # fichier 
    options:      {type:"VARCHAR(32)", default: "'"+("0"*32)+"'"},
    etape_id:     {type:"INTEGER(4)"}, # ID de l'étape courante
    points:       {type:"INTEGER(4)"}, # Nombre total de points

    # Rythme adopté
    # -------------
    # Le rythme adopté pour le programme, de 1 à 10 (en fait de 0 à 9).
    # La valeur 7 est la valeur moyenne, celle qui correspond à une
    # réalisation du programme en un an. Les valeurs supérieures
    # permettent d'écrire en moins de temps, les valeurs inférieures
    # en plus de temps.
    # `duree_absolue`
    rythme:       {type:"INTEGER(1)", constraint:"NOT NULL"},

    created_at:   {type:"INTEGER(10)", constraint:"NOT NULL"},
    updated_at:   {type:"INTEGER(10)", constraint:"NOT NULL"},

  }
end
