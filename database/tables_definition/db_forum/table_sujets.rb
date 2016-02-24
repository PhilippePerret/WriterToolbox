# encoding: UTF-8

def schema_table_forum_sujets
  @schema_table_forum_sujets ||= {

    #  ID
    # ----
    # Identifiant absolu du sujet.
    id:             {type:"INTEGER",      constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Créateur
    # --------
    # ID user du créateur du sujet
    creator_id:     {type:'INTEGER',      constraint:"NOT NULL"},

    # Titre
    # -----
    # Le titre/nom du sujet, tel qu'affiché au-dessus de sa liste
    # de messages
    name:           {type:'VARCHAR(255)', constraint:"NOT NULL"},

    # Catégorie
    # ----------
    # La catégorie du sujet (grand titre)
    categorie:     {type:"INTEGER(2)", constraint:"NOT NULL"},

    #  Options
    # ---------
    # Cf. ./objet/forum/lib/required/sujet/instance/options.rb
    options:        {type:'VARCHAR(32)'},

    #  Dates
    # -------
    updated_at:     {type:"INTEGER(10)"}, # pour classement par dernier message
    created_at:     {type:"INTEGER(10)"}
  }
end
