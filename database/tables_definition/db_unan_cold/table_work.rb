# encoding: UTF-8
=begin

Définition de la table des travaux (works)

C'est une table qui est ajoutée à la base de l'auteur, pas dans la
base générale.

=end
def schema_table_unan_works
  @schema_table_unan_etape ||= {
    id:         {type:"INTEGER",    constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Numéro du travail
    # -----------------
    # Renverra à un travail de la table `absolute_work` qui permet
    # de savoir exactement le but du travail et ce qu'il faut y faire
    work_id:     {type:"INTEGER", constraint:"NOT NULL"},

    # ID de l'auteur
    # ---------------
    # Seulement à titre de rappel puisque les tables des travaux
    # doivent être dispatchées dans des dossiers pour chaque auteur
    # (i.e. chaque auteur possède sa propre base de données avec son
    # travail)
    auteur_id:  {type:"INTEGER",    constraint:"NOT NULL"},


    # Options de 32 chiffres pour des options comme pour les autres
    # classe. Le premier nombre correspond notamment à l'état du
    # travail, par exemple 0: pas encore commencée, 9:achevée
    options:    {type:"VARCHAR(32)", default:"'"+("0"*32)+"'"},

    # Pages lues
    # ----------
    # Consigne la liste des pages de cours lues (ces pages sont
    # définies dans la donnée absolue de l'étape).
    # Chaque page lue rapporte des points pour le travail. Toutes les
    # pages doivent être lues pour que l'auteur puisse passer
    # au travail logique suivant.
    pages_lues: {type:"VARCHAR(255)", default:"NULL"},

    # Nombre de points actuels
    # ------------------------
    # Nombre de points marqués pour ce travail. En sachant que
    # les données absolues de l'étape définissant un `minimum_points`
    # qui correspond au nombre de points minimum qu'il faut pour
    # pouvoir passer au travail suivant.
    # Ces points sont notamment gagnés grâce aux questionnnaires et
    # grâce aux questions "à la volée" posées
    points: {type:"INTEGER(3)",constraint:"NOT NULL", default:0},

    # Questions à la volée
    # --------------------
    # Questions à la volée répondues avec le nombre de points marqués.
    # Chaque question est séparée par un "-" et l'id et le nombre de points
    # sont séparés par ":". Par exemple : "12:3-5:11" signifie que l'auteur
    # a déjà répondu aux questions 12 et 5, qu'il a eu 3 points pour la
    # question 12 et 11 points pour la question 5.
    # L'identifiant correspond à l'ID dans la table "flying_qcms"
    flying_qcms:  {type:"VARCHAR(255)"}
  }
end
