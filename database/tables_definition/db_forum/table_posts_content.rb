# encoding: UTF-8
=begin

Table pour maintenant le contenu des messages

=end
def schema_table_forum_posts_content
  @schema_table_forum_posts_content ||= {

    # ID du message
    # -------------
    # Le même que dans la table posts
    id:  {type:"INTEGER", constraint:"PRIMARY KEY"},

    # Contenu
    # -------
    # Contenu textuel du message
    # ON lui met quand même une limite à l'enregistrement.
    content:  {type:"TEXT", constraint:"NOT NULL"},

    # Date de dernière modification
    # -----------------------------
    # Noter que la date de création se trouve dans les
    # données principales
    updated_at: {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end
