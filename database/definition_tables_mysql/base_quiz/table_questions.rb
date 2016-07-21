# encoding: UTF-8
def schema_table_questions
  <<-MYSQL
CREATE TABLE questions
  (
    id INTEGER AUTO_INCREMENT,

    question VARCHAR(255) NOT NULL,

    #  GROUPE
    # --------
    # Comme les quiz, les questions appartiennent à des groupes.
    # Cela permet simplement de les trier à l'affichage, lorsque plusieurs
    # types de questionnaires appartiennent à la même base. Par exemple, les
    # questionnaire sur le scénodico et sur le filmodico sont tous dans la
    # base 'quiz_biblio'. On peut donc, grâce à ce groupe, obtenir seulement
    # les questions qui appartiennent à l'un ou à l'autre
    #
    # Le groupe ne se définit pas dans le questionnaire de la question,
    # il est automatiquement attribué en fonction du groupe du questionnaire
    # 
    groupe VARCHAR(100),

    # REPONSES
    # ----------------------
    # Puisqu'il s'agit toujours que de QCM, les réponses sont toujours
    # définies et strictes. La donnée est un Array de Hash jsonné.
    # Voir le format dans le programme.
    # Chaque réponse définit sa valeur en points.
    reponses BLOB NOT NULL,


    # INDICATION
    # -----------
    # Une indication optionnelle à ajouter sous la question,
    # en petit, pour aider à faire le choix.
    # Remarquer qu'une indication automatique existe lorsque la question
    # comporte plusieurs choix à cocher (checkbox au lieu de radion).
    indication TEXT,

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
