# encoding: UTF-8
=begin
Pour consigner des valeurs propre à l'user, dans sa table
personnelle.

  set_var <name>, <valeur>

Seuls peuvent être conservés un Fixnum, un string ou une valeur
booléenne.

Pour injection de la table variables_0 :

CREATE TABLE variables_0
  (
    id INTEGER AUTO_INCREMENT,
    name VARCHAR(200),
    value BLOB,
    type INTEGER(1),
    updated_at INTEGER(10),
    created_at INTEGER(10),
    PRIMARY KEY (id)
  );

=end
def schema_table_variables(user_id)
  # debug "-> schema_table_variables(#{user_id}) (création table 'variables_#{user_id}')"
  <<-MYSQL
CREATE TABLE variables_#{user_id}
  (
    # ID
    # ---
    # Toujours un ID, même s'il ne sert à rien ici
    id INTEGER AUTO_INCREMENT,

    # NAME
    # ----
    # Nom de la variable
    name VARCHAR(200),

    # VALUE
    # -----
    # Valeur de la variable
    value BLOB,

    # TYPE
    # ----
    # Type de la variable
    # cf. VARIABLES_TYPES
    type INTEGER(1),

    updated_at INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
