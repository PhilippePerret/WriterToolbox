# encoding: UTF-8
=begin

Table consignant les votes pour les messages

=end
def schema_table_forum_posts_votes
  @schema_table_forum_posts_votes ||= {

    # ID
    # Le même que dans la table principale
    id: {type:"INTEGER", constraint:"PRIMARY KEY"},

    # Valeur actuelle
    # Suivant le type du sujet, ça produit un résultat
    # différent
    vote: {type:"INTEGER(8)", default: "0"},

    # Date de dernier vote
    updated_at: {type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end
