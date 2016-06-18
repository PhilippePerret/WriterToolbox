# encoding: UTF-8
=begin
Tout ce qui concerne les bases de données pour User
=end
class User
  class << self

    def table_users
      @table_users ||= site.dbm_table(:hot, 'users')
    end
    alias :table :table_users

    def table_connexions
      @table_connexions ||= site.dbm_table(:hot, 'connexions')
    end

    def table_paiements
      @table_paiements ||= site.dbm_table(:cold, 'paiements')
    end


  end

end
