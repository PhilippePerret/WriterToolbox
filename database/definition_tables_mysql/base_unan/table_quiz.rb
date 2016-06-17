# encoding: UTF-8
def schema_table_quiz
  <<-MYSQL
CREATE TABLE quiz
  (
    id INTEGER AUTO_INCREMENT,

    #  TITRE
    # -------
    # Le titre unique du questionnaire qui va le caractériser.
    titre VARCHAR(200) NOT NULL,

    #  TYPE
    # ------
    # Pour savoir si c'est un simple quiz, un sondage, une
    # simple prise de renseignements, une validation des
    # acquis, etc.
    # Cf. la carte Unan::Quiz::TYPES
    type INTEGER(2) NOT NULL,

    # QUESTIONS_IDS
    # -------------
    # IDS des questions telles que définies dans la table questions
    # Un QUIZ est un ensemble de questions
    questions_ids VARCHAR(255),

    #  OUTPUT
    # --------
    # Pour ne pas avoir à le reconstruire chaque fois, on enregistre le
    # code du questionnaire dans cette variable.
    output BLOB,

    #  POINTS
    # --------
    # Nombre de points gagnés en cas de réussite au questionnaire
    # Noter qu'on peut donner aussi un nombre de point minimum pour
    # avoir exécuté le questionnaire, même en cas d'échec.
    points INTEGER(3) DEFAULT 0,

    #  OPTIONS
    # ---------
    # Pour définir des options
    # Cf. ./objet/unan/lib/module/quiz/quiz/options.rb
    options VARCHAR(32),

    # DESCRIPTION
    # -----------
    description TEXT,

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
