# encoding: UTF-8

def schema_table_sujets
  <<-MYSQL
CREATE TABLE sujets
  (
    id          INTEGER       AUTO_INCREMENT,
    created_at  INTEGER(10)   NOT NULL,
    updated_at  INTEGER(10),
    creator_id  INTEGER       NOT NULL,
    titre       VARCHAR(255)  NOT NULL,

    # CATEGORIE
    # ---------
    #  La catégorie de ce sujet.
    # Cf. ?
    categorie INTEGER(2) NOT NULL,

    #  OPTIONS
    # ---------
    # Cf. ./objet/forum/lib/required/sujet/instance/options.rb
    options VARCHAR(32) DEFAULT '00000000',

    # LAST_POST_ID
    # ------------
    # Identifiant du dernier message envoyé pour
    # ce sujet
    last_post_id INTEGER,

    #  COUNT
    # -------
    # Nombre total de messages dans le sujet
    count INTEGER(8)  DEFAULT 0,

    #  VIEWS
    # -------
    # Nombre total de fois où ce sujet a été vu
    views INTEGER(8) DEFAULT 0,

    PRIMARY KEY (id)
  );
  MYSQL
end
