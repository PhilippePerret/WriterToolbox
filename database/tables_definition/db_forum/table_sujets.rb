# encoding: UTF-8

def schema_table_forum_sujets
  @schema_table_forum_sujets ||= {
    id:             {type:"INTEGER",      constraint:"PRIMARY KEY AUTOINCREMENT"},
    creator_id:     {type:'INTEGER',      constraint:"NOT NULL"},
    name:           {type:'VARCHAR(250)', constraint:"NOT NULL"},
    categories:     {type:"VARCHAR(250)"}, # liste "X,Y,Z"
    last_message:   {type:'INTEGER'},      # ID du dernier message (ou nil)
    count:          {type:'INTEGER(8)', default: 0},
    options:        {type:'VARCHAR(32)', default: "'"+("0"*32)+"'"},
    updated_at:     {type:"INTEGER(10)"}, # pour classement par dernier message
    created_at:     {type:"INTEGER(10)"}
  }
end
