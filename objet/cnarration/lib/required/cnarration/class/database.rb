# encoding: UTF-8
class Cnarration
  class << self

    def table_pages
      @table_pages ||= site.db.create_table_if_needed('cnarration', 'pages')
    end

    def table_tdms
      @table_tdms ||= site.db.create_table_if_needed('cnarration', 'tdms')
    end

  end #/<<self
end #/Cnarration
