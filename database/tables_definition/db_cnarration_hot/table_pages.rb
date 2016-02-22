# encoding: UTF-8
def schema_table_cnarration_hot_pages
  @schema_table_cnarration_hot_pages ||= {

    id: {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},

    # ID de la page visée
    # -------------------
    page_id:  {type:"INTEGER", constraint:"NOT NULL"},

    # ID de l'user, si identifié
    # --------------------------
    user_id:  {type:"INTEGER"},

    # Note de clarté
    # --------------
    # De 0 à 5
    clarte:  {type:"INTEGER(1)"},

    # Note d'intérêt
    # --------------
    # De 0 à 5
    interet:  {type:"INTEGER(1)"},

    # Commentaire
    # -----------
    # Un commentaire textuel, au cas où
    comment:  {type:"TEXT"},

    created_at: {type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end
