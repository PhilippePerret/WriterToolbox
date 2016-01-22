# encoding: UTF-8
def schema_table_unan_cold_quiz
  @schema_table_unan_cold_quiz ||= {

    #  ID
    # ----
    id:         {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Titre du questionnaire
    # ----------------------
    # Le titre unique du questionnaire qui va le caractériser.
    titre:  {type:"VARCHAR(255)", constraint:"NOT NULL"},

    # Type du questionnaire
    # ---------------------
    # Pour savoir si c'est un simple quiz, un sondage, une
    # simple prise de renseignements, une validation des
    # acquis, etc.
    # Cf. la carte Unan::Quiz::TYPES
    type: {type:"INTEGER(2)", constraint:"NOT NULL"},

    # Liste des questions
    # -------------------
    # IDS des questions telles que définies dans la table questions
    # Un QUIZ est un ensemble de questions
    questions_ids:  {type:"BLOB"},

    # Sortie du questionnaire
    # -----------------------
    # Pour ne pas avoir à le reconstruire chaque fois, on enregistre le
    # code du questionnaire dans cette variable.
    output: {type:"BLOB"},

    # Points supplémentaires
    # ----------------------
    # Nombre de points gagnés en cas de réussite au questionnaire
    # Noter qu'on peut donner aussi un nombre de point minimum pour
    # avoir exécuté le questionnaire, même en cas d'échec.
    points: {type:"INTEGER(3)", constraint:"NOT NULL"},

    # Options
    # -------
    # Pour définir des options
    # BIT 1 : Afficher la description (1) ou non (0)
    # BIT 2 : Ne pas compter les points des questions (1) mais seulement les
    #         points définis dans ce questionnaire.
    options: {type:"VARCHAR(32)"},

    # Description
    #
    description:{type:"TEXT"},

    created_at:  {type:"INTEGER(10)", constraint:"NOT NULL"},
    updated_at:  {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end
