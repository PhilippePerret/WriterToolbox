# encoding: UTF-8
=begin

=end
def schema_table_scenodico_categories
  @schema_table_scenodico_categories ||= {
    id:           {type:'INTEGER',      constraint:'PRIMARY KEY'},
    cate_id:      {type:'VARCHAR(4)',   constraint:'UNIQUE'},
    hname:        {type:'VARCHAR(255)', constraint:'NOT NULL'},
    definition:   {type:'TEXT'}
  }
end
