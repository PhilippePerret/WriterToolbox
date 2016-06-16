# encoding: UTF-8
=begin
Tout ce qui concerne les bases de données pour User
=end
class User
  class << self

    # {BdD::Table} Méthode principale qui permet de créer la table si
    # elle n'existe pas et la retourne
    def create_table_if_needed table_name
      site.db.create_table_if_needed 'users', table_name
    end

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
