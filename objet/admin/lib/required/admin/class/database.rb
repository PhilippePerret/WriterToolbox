# encoding: UTF-8
raise_unless_admin
class Admin
  class << self

    def table_taches
      @table_taches ||= site.db.create_table_if_needed('site_hot', 'todolist')
    end
    alias :table_todolist :table_taches

  end #/ << self
end #/Admin
