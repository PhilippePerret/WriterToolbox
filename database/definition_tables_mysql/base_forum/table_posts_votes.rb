# encoding: UTF-8
=begin

Table consignant les votes pour les messages

=end
def schema_table_posts_votes
  <<-MYSQL
CREATE TABLE posts_votes
  (
    # ID du post
    id          INTEGER,
    # Ajouté pour la version 2.0 :
    created_at  INTEGER(10),
    updated_at  INTEGER(10),

    #  VOTE
    # ------
    # Valeur actuelle du vote. Suitant le type du sujet (Type S),
    # ça produit un résultat différent (classement des posts ou non)
    vote  INTEGER(8) DEFAULT 0,

    # UPVOTES
    # -------
    # Liste des IDs de users ayant voté pour ce post
    # C'est une liste-string avec les IDs séparés par
    # une espace.
    upvotes BLOB,

    # DOWNVOTES
    # ---------
    # Liste des IDs des users ayant voté contre ce post.
    # C'est une liste-string avec les IDs d'user séparés
    # par des espaces
    downvotes BLOB,

    PRIMARY KEY (id)
  );
  MYSQL
end
