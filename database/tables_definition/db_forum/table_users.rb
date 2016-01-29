# encoding: UTF-8
=begin

Table des informations de l'user concernant le forum

Noter que le grade de l'auteur se trouve dans ses données
principales. Peut-être, si ce grade ne sert qu'au forum,
faudra-t-il l'amener ici.

=end
def schema_table_forum_users
  @schema_table_forum_users ||= {

    # ID de l'user
    # Le même que celui qu'il a sur le site
    id: {type:"INTEGER", constraint:"PRIMARY KEY"},

    # Nombre de messages
    #
    posts_count: {type:"INTEGER(8)", constraint:"NOT NULL"},

    # Premier message sur le forum
    # Un hash composé de {at: <timestamp>, id: <id message>}
    first_post: {type:"BLOB"},
    # Dernier message sur le forum
    # UN hash composé de {at: <timestamp>, id: <id message>}
    last_post:  {type:"BLOB"},

    #  Options
    # ---------
    options: {type:"VARCHAR(32)", default:"''"},

    # La création, correspondant au tout premier message
    # ou à l'enregistrement des préférences
    created_at: {type:"INTEGER(10)", constraint:"NOT NULL"},

    # Date de dernière modification
    updated_at: {type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end
