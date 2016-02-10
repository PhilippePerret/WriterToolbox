# encoding: UTF-8

# Schéma de la table 'users' de la base 'users.db'
def schema_table_users_users
  {
    id:           {type:"INTEGER",      constraint:"PRIMARY KEY AUTOINCREMENT"},
    pseudo:       {type:"VARCHAR(40)",  constraint:"NOT NULL"},
    patronyme:    {type:"VARCHAR(255)", constraint:"NOT NULL"},
    mail:         {type:"VARCHAR(255)", constraint:"NOT NULL"},
    cpassword:    {type:"VARCHAR(32)",  constraint:"NOT NULL"},
    salt:         {type:"VARCHAR(32)",  constraint:"NOT NULL"},
    session_id:   {type:"VARCHAR(32)"},
    # Options
    # -------
    # 32 caractères (ou plus) pour spécifier l'user
    # Cf. le fichier ./lib/deep/deeper/required/User/inst_options.rb
    options:      {type:"VARCHAR(32)"},
    sexe:         {type:"BOOLEAN"},
    address:      {type:"TEXT"},
    telephone:    {type:"VARCHAR(10)"},
    created_at:   {type:"INTEGER(10)"},
    updated_at:   {type:"INTEGER(10)"}
  }
end
