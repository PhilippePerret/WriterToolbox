# encoding: UTF-8
=begin
  Table pour des données générales sur les quiz

  À la base, il pourrait y avoir une rangée par quiz

=end
def schema_table_quiz
  <<-MYSQL
CREATE TABLE quiz
  (

    id INTEGER AUTO_INCREMENT,

    # SUFFIX_BASE
    # -----------
    # Suffixe de la base du questionnaire, par exemple 'biblio' pour
    # la base `boite-a-outils_quiz_biblio`
    # C'est dans cette base qu'on trouve le `quiz_id` ci-dessous
    suffix_base VARCHAR(100) NOT NULL,

    #  QUIZ_ID
    # ---------
    # IDentifiant du Quiz, mais dans sa propre base défini par
    # le suffix_base ci-dessus.
    quiz_id INTEGER NOT NULL,

    #  COUNT
    # -------
    # Nombre de fois où le quiz a été soumis
    count INTEGER(5) NOT NULL DEFAULT 0,

    #  MOYENNE
    # ---------
    # La note moyenne obtenue
    moyenne DECIMAL(3,1),

    # NOTE_MIN
    # --------
    # Note minimum obtenue
    note_min DECIMAL(3,1),

    # NOTE_MAX
    # --------
    # Note maximale obtenue
    note_max DECIMAL(3,1),

    # OBSERVATION
    # -----------
    # Un message d'observation quelconque
    observation TEXT,

    #  OPTIONS
    # ---------
    # Toujours des options, mais pas encore utilisées
    options VARCHAR(16) DEFAULT '0000000000000000',

    created_at INTEGER(10) NOT NULL,
    updated_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
