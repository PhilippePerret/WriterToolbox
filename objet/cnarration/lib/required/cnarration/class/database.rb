# encoding: UTF-8
class Cnarration
  class << self

    # -> MYSQL NARRATION
    def table_evaluation
      @table_evaluation ||= site.db.create_table_if_needed('cnarration_hot', 'pages')
    end
    # -> MYSQL NARRATION
    def table_pages
      @table_pages ||= site.db.create_table_if_needed('cnarration', 'pages')
    end

    # -> MYSQL NARRATION
    def table_tdms
      @table_tdms ||= site.db.create_table_if_needed('cnarration', 'tdms')
    end

  end #/<<self
end #/Cnarration
