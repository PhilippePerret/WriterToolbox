# encoding: UTF-8
def schema_table_posts
  <<-MYSQL
CREATE TABLE posts
  (
    id          INTEGER     AUTO_INCREMENT,
    user_id     INTEGER     NOT NULL,
    sujet_id    INTEGER     NOT NULL,
    created_at  INTEGER(10) NOT NULL,
    updated_at  INTEGER(10),

    # PARENT_ID
    # ---------
    # Identifiant du message parent, si ce message est
    # une réponse à un message
    parent_id INTEGER,

    # OPTIONS
    # -------
    # BIT 1 : 0 = non validé, 1 = validé
    options VARCHAR(16) DEFAULT '00000000',

    # VALIDED_BY
    # ----------
    # Identifiant du modérateur ayant validé le message
    valided_by INTEGER,

    # MODIFIED_BY
    # -----------
    # Identifiant du modérateur ayant modifié le
    # message s'il a eu besoin d'être modifié
    modified_by INTEGER,

    PRIMARY KEY (id)
  );
  MYSQL
end
