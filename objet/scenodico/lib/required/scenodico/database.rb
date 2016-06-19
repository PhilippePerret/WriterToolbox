# encoding: UTF-8
class Scenodico
  class << self

    def table_mots
      @table_mots ||= site.dbm_table(:biblio, 'scenodico')
    end

    def table_categories
      @table_categories ||= site.dbm_table(:biblio, 'categories')
    end

  end #/<< self
end #/Scenodico
