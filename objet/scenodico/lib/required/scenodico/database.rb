# encoding: UTF-8
class Scenodico
  class << self

    def table_mots
      @table_mots ||= site.dbm_table(:biblio, 'scenodico')
    end

    # -> MYSQL SCENODICO
    def table_categories
      @table_categories ||= site.db.create_table_if_needed('scenodico', 'categories')
    end

  end #/<< self
end #/Scenodico
