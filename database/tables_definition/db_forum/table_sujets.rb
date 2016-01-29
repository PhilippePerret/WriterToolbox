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

    # Catégories
    # ----------
    # Liste des catégories (IDs) auquel appartient le sujet
    #
    categories:     {type:"VARCHAR(250)"}, # liste "X Y Z"

    #  Options
    # ---------
    # BIT 1
    #   Peut-être pour savoir si le sujet est clos ou non ?
    # BIT 2
    #   Le type du sujet, c'est-à-dire un sujet de forum normal, où
    #   les messages se suivent ou un sujet où une question est posée
    #   et on vote pour des réponses données.
    options:        {type:'VARCHAR(32)'},

    #  Dates
    # -------
    updated_at:     {type:"INTEGER(10)"}, # pour classement par dernier message
    created_at:     {type:"INTEGER(10)"}
  }
end
