# encoding: UTF-8
=begin

Table des projets

=end
def schema_table_unan_hot_projets
  @schema_table_unan_projets ||= {

    id:           {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},

    titre:        {type:"VARCHAR(255)"}, # pas obligatoire
    auteur_id:    {type:"INTEGER", constraint:"NOT NULL"},
    program_id:   {type:"INTEGER", constraint:"NOT NULL"},

    resume:       {type:"TEXT"},

    specs:        {type:"VARCHAR(32)"},

    created_at:   {type:"INTEGER(10)", constraint:"NOT NULL"},
    updated_at:   {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end
