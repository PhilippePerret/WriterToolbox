# encoding: UTF-8
def schema_table_forum_sujets_posts
  @schema_table_forum_sujets_posts ||= {

    # ID
    # Identifiant du sujet, le même que dans la table sujets
    id: {type:"INTEGER", constraint:"PRIMARY KEY"},

    # ID du dernier message
    last_post_id: {type:'INTEGER'},

    # Nombre total de messages dans le sujet
    count: {type:'INTEGER(8)',   default:0},

    # Nombre total de vues
    views: {type:"INTEGER(8)", default:0},

    # Dernière actualisation
    updated_at: {type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end
