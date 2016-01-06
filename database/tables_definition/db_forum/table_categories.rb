# encoding: UTF-8
def schema_table_forum_categories
  @schema_table_forum_categories ||= {
    id:           {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},
    name:         {type:"VARCHAR(250)", constraint:"NOT NULL"},
    parent:       {type:"INTEGER"},
    description:  {type:"TEXT"}
  }
end
