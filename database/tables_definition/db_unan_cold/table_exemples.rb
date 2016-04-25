# encoding: UTF-8
=begin
Table 'exemples' permettant d'enregistrer des exemples de
résultats pour chaque travail, exemples tirés ou
inspirés de films ou totalement invnentés.

Permet d'alimenter la propriété `exemples` des étapes absolues
=end
def schema_table_unan_cold_exemples
  @schema_table_unan_cold_exemples ||= {

    # ID de l'exemple
    # ---------------
    id: {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Titre de l'exemple
    # ------------------
    # Doit être assez cours, simplement pour affichage dans un
    # listing. Ça peut être "Fondamentales de Babe" ou
    # "Synopsis de Titanic" (ne pas utiliser "Exemple" qui sera
    # ajouté)
    titre:  {type:"VARCHAR(255)", constraint:"NOT NULL"},

    # Le travail visé
    # ---------------
    # ID du travail dont cet exemple est l'illustration, dans la
    # table `absolute_works`.
    work_id: {type:"INTEGER"},

    # Contenu de l'exemple
    # --------------------
    content: {type:"TEXT", constraint:"NOT NULL"},

    # Notes sur l'exemple
    notes: {type:"TEXT"},

    # Source de l'exemple
    # -------------------
    # Description de la source de l'exemple, lorsqu'il vient d'un
    # film, ou d'un livre, ou d'une illustration propre au cours,
    # etc.
    source: {type:"TEXT", constraint:"NOT NULL"},

    # Type de la source
    # -----------------
    # Suite de bits définissant le type de la source
    # BIT 1 : 0:indéfini, 1:film, 2:livre, 3:perso, 9:autre
    # BIT 2-5 : Année de la source
    # BIT 6-7 : Pays de la source ("fr" = français, "us" = USA, etc.)
    source_type: {type:"VARCHAR(16)", default:"'"+("0"*16)+"'"},

    # Date de création de l'exemple
    created_at:{type:"INTEGER(10)",constraint:"NOT NULL"},
    # Date de modification de l'exemple
    updated_at:{type:"INTEGER(10)",constraint:"NOT NULL"}
  }
end
