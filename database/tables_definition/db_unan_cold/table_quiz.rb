# encoding: UTF-8
def schema_table_unan_cold_quiz
  @schema_table_unan_cold_quiz ||= {
    id:         {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Titre du questionnaire
    # ----------------------
    # Le titre unique du questionnaire qui va le caractériser.
    titre:  {type:"VARCHAR(255)", constraint:"NOT NULL"},

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
    points_if_success: {type:"INTEGER(3)", constraint:"NOT NULL"},

    created_at:  {type:"INTEGER(10)", constraint:"NOT NULL"},
    updated_at:  {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end