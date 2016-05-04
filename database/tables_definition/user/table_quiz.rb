# encoding: UTF-8
=begin

Définition de la table `quiz` de l'user qui enregistre ses
réponses aux divers questionnaires.
Cette table est enregistrée dans la base de données propre à chaque
auteur et propre au programme suivi.
=end
def schema_table_user_quiz
  @schema_table_user_quiz ||= {

    # Identifiant unique (mais seulement pour cette table propre
    # à l'auteur)
    id: {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},

    # ID du questionnaire
    # -------------------
    # ID unique du questionnaire dans la table des questionnaires.
    # Noter un point important concernant les versions : un même
    # questionnaire peut avoir plusieurs versions avec le temps,
    # mais chaque version était consignée dans un enregistrement
    # différent, cette donnée quiz_id correspond toujours à la
    # bonne version du questionnaire. Cela évite les problèmes dans
    # le cas où une question est enlevée ou ajoutée à un questionnaire
    # par la suite, ce qui arrivera fatalement.
    quiz_id:{type:"INTEGER", constraint:"NOT NULL"},

    # ID du travail de l'auteur
    # --------------------------
    # ID du travail Unan::Program::Work correspondant à ce
    # questionnaire précisément.
    # Noter un point important :
    #   * Cet ID peut ne pas être défini, quand le quiz n'a pas encore été
    #     marqué "démarré".
    #
    work_id: {type:"INTEGER"},

    # Type du questionnaire
    # ---------------------
    # Pour simplification du traitement des questionnaires. Avec ce
    # type, on peut savoir si ce doit être un questionnaire de validation
    # des acquis, une simple prise d'informations, etc.
    # Cf. Unan::Quiz::TYPES
    type: {type:"INTEGER(1)", constraint:"NOT NULL"},

    # Max de points possible
    # -----------------------
    # Cette valeur est fixe et n'est enregistrée ici que pour simplifier
    # le traitement des questionnaires
    max_points:{ type:"INTEGER(4)" },

    # Réponses
    # --------
    # {Hash} de données des réponses. C'est un Hahs avec en
    # clé l'identifiant de la question (id absolu dans la table
    # des questions) et en valeur un hash définissant :
    #   <question id> => {
    #       qid:      <question id> pour rappel
    #       type:     <type réponses sur 3 lettres — pour js>
    #       value:    L'ID de la réponse ou la liste des ID de
    #                 réponse si checkbox ou select-multiple
    #       points:   Les points marqués sur cette question par la
    #                 réponse.
    #     }
    reponses: {type:"BLOB"},

    # Points marqués
    # ---------------
    # Le total des points marqué par l'auteur avec ce questionnaire
    points: {type:"INTEGER(4)"},

    # Date où ce questionnaire a été exécuté
    # --------------------------------------
    created_at: {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end
