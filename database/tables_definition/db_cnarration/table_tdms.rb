# encoding: UTF-8
def schema_table_cnarration_tdms
  @schema_table_cnarration_tdms ||= {

    # = ID du livre =
    # Correspond à la constante Cnarration::LIVRES
    id:  {type:"INTEGER", constraint:"PRIMARY KEY"},

    # = ORDER =
    #
    # Liste des IDs de page (table cnarration.pages)
    tdm:  {type:"BLOB", constraint:"NOT NULL"},

    updated_at:{  type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end
