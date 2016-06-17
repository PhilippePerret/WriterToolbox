# encoding: UTF-8
=begin

Définition de la table `quiz` de l'user qui enregistre ses
réponses aux divers questionnaires.
Cette table est enregistrée dans la base de données propre à chaque
auteur et propre au programme suivi.
=end
def schema_table_unan_quiz(user_id)
  <<-MYSQL
CREATE TABLE unan_quiz_#{user_id}
  (
    # ID
    # --
    # IDentifiant unique et universel d'un questionnaire
    # rempli par l'auteur
    id INTEGER AUTO_INCREMENT,

    # PROGRAM_ID
    # ----------
    # ID du programme contenant ce questionnaire
    # (car tous les questionnaires de tous les programems d'un
    #  auteur sont consignés dans cette table propre à l'auteur)
    program_id INTEGER NOT NULL,

    # QUIZ_ID
    # -------
    # ID absolu du questionnaire absolu.
    quiz_id INTEGER NOT NULL,

    # WORK_ID
    # -------
    # ID du travail
    # Cet ID peut ne pas avoir été défini, si le travail n'a
    # pas encore été marqué démarré.
    work_id INTEGER,

    # TYPE
    # ----
    # Le type du questionnaire (pour simplifier le traitement
    # du questionnaire). Définit si c'est une validation des
    # acquis, un simple quiz, etc.
    type INTEGER(1) NOT NULL,

    # MAX_POINTS
    # ----------
    # Le maximum de points qu'on pouvait gagner avec ce
    # questionnaire
    max_points INTEGER(4),

    # REPONSES
    # --------
    # Les réponses données par l'auteur au questionnaires
    # C'est un Hash-String avec en clé l'id de la question
    # (dans la table des questions) et en valeur un hash
    # définissant :
    #   {
    #     qid: <id question pour rappel>,
    #     type:  <type de réponses sur 3 lettres - pour JS>
    #     value: <id de la réponse ou liste des id de réponse
    #     points:  <points marqués sur cette question>
    #    }
    reponses BLOB,

    # POINTS
    # ------
    # Points marqués par l'auteur avec ce questionnaire.
    points INTEGER(4),

    # CREATED_AT
    # ----------
    # Timestmamp de l'heure où ce questionnaire a été
    # soumis
    created_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
