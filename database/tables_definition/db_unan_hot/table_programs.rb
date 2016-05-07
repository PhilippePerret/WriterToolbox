# encoding: UTF-8
=begin

Définition de la table pour un programme “Un An Un script”
Ce sont les données générales

=end
def schema_table_unan_hot_programs
  @schema_table_unan_programs ||= {
    id:           {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},
    auteur_id:    {type:"INTEGER", constraint:"NOT NULL"},

    # ID du projet ({Unan::Projet})
    projet_id:    {type:"INTEGER"},

    # Aperçu des jours
    # ----------------
    # Cf. le fichier Days-Overview.md
    # Pour avoir un aperçu de tous les jours
    days_overview:   {type:"CLOB(230)"},

    # Jour-programme courant
    # ----------------------
    # L'identifiant de 1 à 366 du jour-programme
    # actuel de l'auteur.
    current_pday:  {type:"INTEGER(3)", constraint:"NOT NULL", default:1},

    # Démarrage du jour-programme courant
    # -----------------------------------
    # Timestamp (nombre de secondes) du démarrage du jour-programme
    # current_pday (entendu que la date du démarrage du programme ne
    # suffit pas puisque l'utilisateur peut modifier son rythme quand
    # il le veut).
    current_pday_start: {type:"INTEGER(10)", constraint:"NOT NULL"},


    # Options
    # -------
    # Pour la définition de chaque bit des options, cf. le
    # fichier
    options:      {type:"VARCHAR(32)", default: "'"+("0"*32)+"'"},

    # Nombre de points
    # ----------------
    points:       {type:"INTEGER(8)"},

    # Retards
    # --------
    # Variable qui consigne les retards de l'auteur. Chaque octet
    # est un jour du programme, avec une valeur qui peut aller
    # de 0 (aucun retard) à 8 (trop de gros retards)
    # Cette variable permet de savoir comment l'auteur a travaillé
    # jusque-là.
    retards:      {type:"TEXT"},

    # Rythme adopté
    # -------------
    # Le rythme adopté pour le programme, de 1 à 10 (en fait de 0 à 9).
    # La valeur 5 est la valeur moyenne, celle qui correspond à une
    # réalisation du programme en un an. Les valeurs supérieures
    # permettent d'écrire en moins de temps, les valeurs inférieures
    # en plus de temps.
    # `duree_absolue`
    rythme:       {type:"INTEGER(1)", constraint:"NOT NULL"},

    created_at:   {type:"INTEGER(10)", constraint:"NOT NULL"},
    updated_at:   {type:"INTEGER(10)", constraint:"NOT NULL"},

  }
end
