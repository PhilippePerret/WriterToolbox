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
  @schema_table_unan_user_variables ||= {
      name:   {type:"VARCHAR(200)", constraint:"UNIQUE"},
      value:  {type:"BLOB"},
      type:   {type:"INTEGER(1)"}
        # Pour le type, cf. VARIABLES_TYPES
    }
end
