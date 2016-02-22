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

    def table_paiements
      @table_paiements ||= create_table_if_needed('paiements')
    end

    def table_users
      @table_users ||= create_table_if_needed('users')
    end
    alias :table :table_users

    # Attention : Il s'agit de la base de données commune, avec tous
    # les users, pas la base de données propre à chaque user (cf. + bas)
    def database
      @database ||= BdD::new(database_path.to_s)
    end

    def database_path
      @database_path ||= site.folder_db + 'users.db'
    end

  end

  # ---------------------------------------------------------------------
  #   Instances
  # ---------------------------------------------------------------------

end
