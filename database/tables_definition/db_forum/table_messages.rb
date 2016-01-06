# encoding: UTF-8
def schema_table_forum_messages
  @schema_table_forum_messages ||= {
    id:           {type:"INTEGER",      constraint:"PRIMARY KEY AUTOINCREMENT"},
    user_id:      {type:'INTEGER',      constraint:"NOT NULL"},
    parent_id:    {type:'INTEGER'} # ID message parent (if any)
    content:      {type:"TEXT",         constraint:"NOT NULL"},
    options:       type:"VARCHAR(32)",  default:"'"+("0"*32)+"'"},
    valided_by:   {type:'INTEGER'},   # ID du modérateur qui a validé le message
    modified_by:  {type:'INTEGER'},   # ID du modificateur du message (if any)
    created_at:   {type:'INTEGER',      constraint:"NOT NULL"},
    updated_at:   {type:'INTEGER',      constraint:"NOT NULL"}
  }
end
