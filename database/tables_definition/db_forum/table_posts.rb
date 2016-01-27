# encoding: UTF-8
def schema_table_forum_posts
  @schema_table_forum_posts ||= {
    id:           {type:"INTEGER",      constraint:"PRIMARY KEY AUTOINCREMENT"},
    user_id:      {type:'INTEGER',      constraint:"NOT NULL"},

    # ID du sujet
    # -----------
    sujet_id:     {type:'INTEGER',      constraint:"NOT NULL"},

    # ID message parent (if any)
    parent_id:    {type:'INTEGER'},
    content:      {type:"TEXT",         constraint:"NOT NULL"},
    #  Options
    # ---------
    # String de 32 caractères max
    # BIT 1   SI 0, non validé, si 1:validé
    #
    options:      {type:"VARCHAR(32)"},

    valided_by:   {type:'INTEGER'},   # ID du modérateur qui a validé le message
    modified_by:  {type:'INTEGER'},   # ID du modificateur du message (if any)

    created_at:   {type:'INTEGER(10)',      constraint:"NOT NULL"},
    updated_at:   {type:'INTEGER(10)',      constraint:"NOT NULL"}
  }
end
