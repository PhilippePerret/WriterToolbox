# encoding: UTF-8
=begin

Table des projets

=end
def schema_table_unan_archives_projets
  @schema_table_unan_archives_projets ||= begin
    require './database/tables_definition_mysql/base_unan/table_projets.rb'
    schema_table_unan_hot_projets
  end
end
