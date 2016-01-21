# encoding: UTF-8
def schema_table_unan_cold_questions
  @schema_table_unan_flying_qcms ||= {
    id:         {type:"INTEGER", constraint:"PRIMARY KEY AUTOINCREMENT"},

    # La question
    question:   {type:"VARCHAR(255)", constraint:"NOT NULL"},

    # Les réponses possibles
    # ----------------------
    # Puisqu'il s'agit toujours que de QCM, les réponses sont toujours
    # définies et strictes. La donnée est un Hash jsonné.
    # Voir le format dans le programme.
    # Chaque réponse définit sa valeur en points.
    reponses:   {type:"BLOB", constraint:"NOT NULL"},

    # Type du QCM
    # -----------
    # 4 Chiffres qui définissent
    #   bit 1     : r: un seul choix possible, c: choix multiple
    #               => type_c
    #   bit 2     : type d'affichage l: en ligne, c: en colonne, m: menu
    #               => type_a
    type:     {type:"VARCHAR(16)", constraint:"NOT NULL", default: "'"+("0"*16)+"'"},

    # Raison de la réponse
    # --------------------
    # Pour expliquer la bonne réponse si nécessaire
    raison:  {type:"TEXT"},

    created_at: {type:"INTEGER(10)", constraint:"NOT NULL"},
    updated_at: {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end
