# encoding: UTF-8
def schema_table_unan_cold_flying_qcms
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
    #   bit 1     : 0: un seul choix possible, 1: choix multiple
    #   bit 2     : type d'affichage 0: en ligne, 1: en colonne, 2: menu
    #   bit 3     : type de question, parmi des choses comme "connaissance",
    #               "travail personnel", etc.
    #   bit 4     : Cible de la question, 0:histoire, 1:personnage, etc.
    #   bit 5     : Sous-cible de la question, par exemple si 0:histoire,
    #               alors 0:pitch, 1:synopsis, si 1:personnage pour le bit
    #               4 alors 0:dialogue, 1:caractéristiques, etc.
    type:     {type:"VARCHAR(16)", constraint:"NOT NULL", default: "'"+("0"*16)+"'"}
  }
end
