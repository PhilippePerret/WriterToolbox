# encoding: UTF-8
class Cnarration
  class << self
    def table_evaluation
      @table_evaluation ||= site.dbm_table(:cnarration, 'comments')
    end
    def table_pages
      @table_pages ||= site.dbm_table(:cnarration, 'narration')
    end
    def table_tdms
      @table_tdms ||= site.dbm_table(:cnarration, 'tdms')
    end
  end #/<<self
end #/Cnarration
