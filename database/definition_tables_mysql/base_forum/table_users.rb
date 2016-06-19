# encoding: UTF-8
=begin

Table des informations de l'user concernant le forum

Noter que le grade de l'auteur se trouve dans ses données
principales. Peut-être, si ce grade ne sert qu'au forum,
faudra-t-il l'amener ici.

=end
def schema_table_users
  <<-MYSQL
CREATE TABLE users
  (
    id INTEGER,

    # POSTS_COUNT
    # -----------
    # Nombre de messages envoyés par l'user
    posts_count INTEGER(8) DEFAULT 0,

    # OPTIONS
    # -------
    # Options de l'user sur le forum
    # cf.
    options VARCHAR(32) DEFAULT '00000000',

    # LAST_POST
    # ---------
    # Le dernier message posté sur le forum
    # C'est un Hash json contenant at: (timestamp) et
    # :id (identifiant du message)
    last_post BLOB,

    created_at INTEGER(10) NOT NULL,
    updated_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
