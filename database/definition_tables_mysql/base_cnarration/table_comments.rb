# encoding: UTF-8
def schema_table_comments
  <<-MYSQL
CREATE TABLE comments
  (
    id          INTEGER AUTO_INCREMENT,
    page_id     INTEGER NOT NULL,
    user_id     INTEGER,
    created_at  INTEGER(10) NOT NULL,

    # CLARTE
    # ------
    # Note de clarté de 0 à 5
    clarte INTEGER(1),

    # INTERET
    # -------
    # Note d'intérêt de la page, de 0 à 5
    interet INTEGER(1),

    # COMMENT
    # -------
    # Commentaire textuel de l'user sur la page
    comment TEXT,

    PRIMARY KEY (id)
  );
  MYSQL
end
