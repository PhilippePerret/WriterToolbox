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
def schema_table_unan_user_variables
  @schema_table_unan_user_variables ||= begin
    # l'ID n'est pas utilisé, sert seulement pour pouvoir utiliser
    # la table avec la classe BdD
    id:     {type:"INTEGER",      constraint:"AUTOINCREMENT"},
    name:   {type:"VARCHAR(200)", constraint:"PRIMARY KEY"},
    value:  {type:"BLOB"},
    type:   {type:"INTEGER(1)"}
      # Pour le type, cf. VARIABLES_TYPES
  end
end
