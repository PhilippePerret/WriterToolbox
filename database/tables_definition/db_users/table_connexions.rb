# encoding: UTF-8

# Schéma de la table 'connexions' de la base 'users.db'
# Cette table permet de mémoriser les dates de dernières connexions
# des users
def schema_table_users_connexions
  {
    # ID
    # --
    # L'identifiant de l'user
    id:    {type: 'INTEGER', constraint:'PRIMARY KEY AUTOINCREMENT'},
    # Time
    # ----
    # Le timestamp de la dernière connexion
    time:       {type: 'INTEGER(10)', constraint: 'NOT NULL'},
    # Route
    # -----
    # La dernière route empruntée
    route:      {type: 'VARCHAR(255)'}
  }
end
