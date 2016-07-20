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

    #  GROUPE
    # --------
    # Pour savoir dans quel groupe de questionnaires il se trouve.
    # Par exemple, les questionnaire sur le scénodico sont dans le
    # groupe 'scenodico' de la base générale `quiz_biblio` qui contient
    # tous les questionnaires sur les biblios, donc le scénodico et le
    # filmodico.
    groupe VARCHAR(100),

    #  TYPE
    # ------
    # Pour savoir si c'est un simple quiz, un sondage, une
    # simple prise de renseignements, une validation des
    # acquis, etc.
    # Cf. la carte Quiz::TYPES
    type INTEGER(1) NOT NULL,

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

    #  OPTIONS
    # ---------
    # Pour définir des options
    # Cf. ./lib/deep/deeper/module/quiz/questionnaire/options.rb
    options VARCHAR(16),

    # DESCRIPTION
    # -----------
    # Description pour l'utilisateur
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
