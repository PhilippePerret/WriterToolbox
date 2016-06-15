# encoding: UTF-8
class BdD
  class Table

    # Types de données
    DATA_TYPES = [
      "NULL",
      "INTEGER", "INT", "TINYINT", "SMALLINT", "MEDIUMINT", "BIGINT", "UNSIGNED BIG INT", "INT2", "INT8",
      "REAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT",
      "NUMERIC", "DECIMAL",
      "CHAR", "CHARACTER", "NCHAR", "VARCHAR", "TEXT", "CLOB",
      "BLOB",
      "BOOLEAN",
      "DATE", "DATETIME"
    ]

    # Types de contraintes
    CONSTRAINT_TYPES = [
      "NOT NULL", "UNIQUE", "PRIMARY KEY", "AUTOINCREMENT",
      # Contraintes avec valeurs
      "DEFAULT", "CHECK"
    ]

    class << self

      ##
      # Return TRUE si la table +table_name+ ({String}) existe dans
      # la base de données +bdd+ ({BdD})
      def table_exist? bdd, table_name
        begin
          bdd.execute "SELECT 1 FROM #{table_name} LIMIT 1;"
          true
        rescue Exception => e
          false
        end
      end
      alias :exist? :table_exist?

      ##
      # Retourne la liste des tables de la base de données +bdd+
      def table_names bdd
        res = bdd.execute"SELECT * FROM sqlite_master WHERE type = 'table';"
        unless false == res
          arr = res.collect do |row|
            row[1]
          end
          arr.delete("sqlite_sequence")
          arr.delete("__column_names__") # ancienne version
        else
          error "Impossible de récupérer la liste des tables de la base de données…"
          arr = []
        end
        return arr
      end

    end # << self
  end # Table
end # BdD
