# encoding: UTF-8
=begin
Définition du schéma de la table contenant les mots du scénodico
=end
def schema_table_scenodico
  <<-MYSQL
CREATE TABLE scenodico
  (
    id          INTEGER       AUTO_INCREMENT,
    mot         VARCHAR(255)  NOT NULL,
    definition TEXT           NOT NULL,

    categories  VARCHAR(200),
    synonymes   VARCHAR(200),
    contraires  VARCHAR(200),
    relatifs    VARCHAR(200),

    # LIENS
    # -----
    # Non encore définis
    liens       BLOB,

    # TYPE_DEF
    # --------
    # Le type du mot, pour savoir si c'est un mot réellement
    # de scénariste ou un mot pour le site par exemple.
    type_def    INTEGER(1),

    updated_at  INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
