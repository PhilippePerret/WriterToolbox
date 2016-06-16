# encoding: UTF-8
=begin
Pour consigner des valeurs propre à l'user, dans sa table
personnelle.

Pour enregistrer une valeur dans cette table on utilise
l'extension Unan :

  User::set_var <name>, <valeur>

<valeur> doit être un numbre fixnum, un string ou une valeur
booléenne.

=end
def schema_table_variables(user_id)
  <<-MYSQL
CREATE TABLE variables_#{user_id}
  (
    # NAME
    # ----
    # Nomm de la variable
    name VARCHAR(200) UNIQUE,

    # VALUE
    # -----
    # Valeur de la variable
    value BLOB,

    # TYPE
    # ----
    # Type de la variable
    # cf. VARIABLES_TYPES
    type INTEGER(1),

    PRIMARY KEY (name)
  )
  MYSQL
end
