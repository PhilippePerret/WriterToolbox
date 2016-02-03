# encoding: UTF-8
=begin
Schéma de la table contenant les tickets
=end
def schema_table_site_hot_tickets
  @schema_table_site_hot_tickets ||= {
    id:         {type:"VARCHAR(32)",  constraint:"NOT NULL"},
    code:       {type:"BLOB",         constraint:"NOT NULL"},
    user_id:    {type:"INTEGER",      constraint:"NOT NULL"},
    created_at: {type:"INTEGER(10)",  constraint:"NOT NULL"},
    updated_at: {type:"INTEGER(10)",  constraint:"NOT NULL"}
  }
end
