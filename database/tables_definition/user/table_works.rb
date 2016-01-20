# encoding: UTF-8
=begin

Définition de la table des travaux (works)

C'est une table qui est ajoutée à la base de l'auteur, pas dans la
base générale.

=end
def schema_table_user_works
  @schema_table_unan_etape ||= {
    # Bien tenir compte du fait que cet identifiant est unique pour
    # l'user mais pas pour "le monde". Les users possèdent les
    # même identifiants. Donc s'il fallait les "couper" (dans un bureau
    # d'administration par exemple) il faudrait penser à les associer
    # toujours à l'utilisateur.
    # Noter également que ce ID N'EST PLUS LE MÊME que celui du travail
    # absolu correspondant. Car un même travail absolu peut donner
    # lieu à plusieurs travaux propres au programme. C'est maintenant
    # la propriété `abs_work_id` qui contient l'identifiant du travail
    # absolu.
    id: {type:"INTEGER",    constraint:"PRIMARY KEY AUTOINCREMENT"},

    # ID du program
    # -------------
    # Pour rappel, puisqu'on pourrait le trouver par rapport au nom
    # de la base de données auquel appartient le work courant
    program_id: {type:"INTEGER", constraint:"NOT NULL"},

    # ID du travail absolu correspondant
    abs_work_id: {type:"INTEGER", constraint:"NOT NULL"},

    # État du travail
    # ---------------
    # Nombre de 0 à 9 qui indique où en est le travail.
    # Noter que chaque élément de l'user possède cette propriété
    # `status` pour savoir où il en est. Elle renvoie chaque fois à
    # une liste propre décrivant le status.
    status: {type:"INTEGER(1)", contraint:"NOT NULL", default:0},

    # Options
    # -------
    # Cf. le document Program > Works.md du RefBook
    options:    {type:"VARCHAR(64)"},

    # Nombre de points actuels
    # ------------------------
    # Nombre de points marqués pour ce travail. En sachant que
    # les données absolues de l'étape définissant un `minimum_points`
    # qui correspond au nombre de points minimum qu'il faut pour
    # pouvoir passer au travail suivant.
    # Ces points sont notamment gagnés grâce aux questionnnaires et
    # grâce aux questions "à la volée" posées
    points: {type:"INTEGER(3)",constraint:"NOT NULL", default:0},

    updated_at: {type:"INTEGER(10)", constraint:"NOT NULL"},
    created_at: {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end
