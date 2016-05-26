# encoding: UTF-8
=begin

  Table contenant les programmes UN AN UN SCRIPT archivés,
  soit parce qu'ils ont été terminés soit parce qu'ils ont
  été abandonnés

=end
def schema_table_unan_archives_programs
  @schema_table_unan_archives_hot_programs ||= begin
    require './database/tables_definition/db_unan_hot/table_programs.rb'
    schema_table_unan_hot_programs
  end
end
