# encoding: UTF-8
=begin
Définition du schéma de la table contenant les mots du scénodico
=end
def schema_table_scenodico_mots
  @schema_table_resources_scenodico ||= {
    id:   {type:"INTEGER", constraint:"PRIMARY KEY"},
    mot:  {type:"VARCHAR(255)", constraint:"NOT NULL"},

    definition:{type:"TEXT", constraint:"NOT NULL"},

    id_interdata:{type:'VARCHAR(255)', constraint:'NOT NULL'},

    categories: {type:'BLOB'},
    synonymes: {type:'BLOB'},
    contraires: {type:'BLOB'},
    relatifs: {type:'BLOB'},

    liens:{type:'BLOB'},

    type_def:{type:'INTEGER(1)'}

  }
end
