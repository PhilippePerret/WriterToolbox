# encoding: UTF-8
def schema_table_users_paiements
  @schema_table_users_paiements ||= {
    id:           {type:"INTEGER",      constraint:"PRIMARY KEY AUTOINCREMENT"},
    user_id:      {type:"INTEGER",      constraint:"NOT NULL"},
    objet_id:     {type:"VARCHAR(200)", constraint:"NOT NULL"},
    montant:      {type:"INTEGER(4)",   constraint:"NOT NULL"},
    facture:      {type:"VARCHAR(32)",  constraint:"NOT NULL"},
    created_at:   {type:"INTEGER(10)"}
  }
end
