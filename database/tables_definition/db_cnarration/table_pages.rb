# encoding: UTF-8
def schema_table_cnarration_pages
  @schema_table_cnarration_pages ||= {
    id:       {type:"INTEGER",      constraint:"PRIMARY KEY AUTOINCREMENT"},

    # = Handler =
    # Ce sera principalement le nom du fichier dans le dossier
    #
    handler:  {type:"VARCHAR(200)", constraint:"NOT NULL"},

    # = ID du livre =
    livre_id:  {type:"INTEGER(2)", constraint:"NOT NULL"},

    # = Titre =
    # Titre de la page qui sera utilisé notamment dans les
    # tables des matières et les titres de page
    titre:    {type:"VARCHAR(255)", constraint:"NOT NULL"},

    # = Description de la page =
    description:  {type:"TEXT"},
    
    # = Options =
    # Cf. ./
    options:  {type:"VARCHAR(32)"},

    created_at:{type:"INTEGER(10)", constraint:"NOT NULL"},
    updated_at:{type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end
