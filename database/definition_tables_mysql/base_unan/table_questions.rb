# encoding: UTF-8
def schema_table_questions
  <<-MYSQL
CREATE TABLE questions
  (
    id INTEGER AUTO_INCREMENT,

    question VARCHAR(255) NOT NULL,

    # INDICATION
    # -----------
    # Une indication optionnelle à ajouter sous la question,
    # en petit, pour aider à faire le choix.
    # Remarquer qu'une indication automatique existe lorsque la question
    # comporte plusieurs choix à cocher (checkbox au lieu de radion).
    indication TEXT,

    # REPONSES
    # ----------------------
    # Puisqu'il s'agit toujours que de QCM, les réponses sont toujours
    # définies et strictes. La donnée est un Array de Hash jsonné.
    # Voir le format dans le programme.
    # Chaque réponse définit sa valeur en points.
    reponses BLOB NOT NULL,

    #  TYPE
    # ------
    # Types de la question
    #   bit 1     : r: un seul choix possible, c: choix multiple
    #               => type_c
    #   bit 2     : type d'affichage l: en ligne, c: en colonne, m: menu
    #               => type_a
    type VARCHAR(16) DEFAULT '00000000',

    #  RAISON
    # --------
    # Pour expliquer la bonne réponse si nécessaire
    raison TEXT,

    # CREATED_AT
    # ----------
    # Timestamp de la création du projet
    created_at INTEGER(10),

    # UPDATED_AT
    # ----------
    # Timestamp de la modification de cette donnée
    updated_at INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
