# encoding: UTF-8
=begin

Définition de la table `absolute_works` qui définit précisément tous
les travaux à accomplir pour arriver au bout du scénario.

=end
def schema_table_unan_absolute_works
  @schema_table_unan_absolute_works ||= {

    # ID absolu du travail
    # Correspond à la propriété `work_id` des travaux des auteurs (works)
    id:         {type:"INTEGER",    constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Titre du travail
    # ----------------
    # Un titre générique pour le travail
    # Noter qu'un "jour-programme" peut avoir plusieurs titres
    titre:      {type:"VARCHAR(250)", constraint:"NOT NULL"},

    # Jour de départ
    # --------------
    # Le programme-jour (de 1 à 365) où l'étape doit être commencée.
    # Pour rappel, des étapes peuvent se chevaucher, donc il est important,
    # pour chaque étape, de préciser son jour départ et sa durée
    pday_start:  {type:"INTEGER(3)", constraint:"NOT NULL"},

    # Durée absolue du travail
    # ------------------------
    # C'est la durée absolue (en programmes-jours) dans laquelle ce
    # travail doit être effectué. Il variera en fonction du `rythme`
    # choisi par l'auteur
    duree:        {type:"INTEGER(3)", constraint:"NOT NULL"},

    # Le type de l'étape
    # ------------------
    # Il est constitué de 8 chiffres/lettres définissant 8 paramètres
    # pour le type. Par exemple, le premier paramètres correspond la
    # cible principal du travail de l'étape, à savoir: 0:histoire,
    # 1:structure, 2:personnage, 3:dialogue, 4:thematique etc. (ces
    # nombres sont donnés en pure illustration et ne correspondent
    # pas à une réalité)
    # Ce champ rassemble donc plusieurs propriétés du champ d'édition
    # de l'étape. dont :
    #   sujet_cible
    type:       {type:"VARCHAR(8)", constraint:"NOT NULL"},


    # Travail général
    # ---------------
    # La définition générale du travail (TEXT). Il pourra être précisé
    # dans d'autres propriétés
    travail:    {type:"TEXT", constraint:"NOT NULL"},

    # Étape précédente
    # ----------------
    # Lorsque l'étape de travail fait suite à une autre, par exemple lorsqu'il
    # faut reprendre le document d'une étape précédente, on l'indique par ce
    # biais
    # Cette donnée est donc fortement liée à la notion de développement en
    # spirale.
    previous_etape: {type:'INTEGER(4)', default:"NULL"},

    # Résultat du travail
    # -------------------
    # Le document qui doit être le résultat de ce travail, de façon
    # littéraire (marchera de paire avec la propriété type_resultat)
    resultat:   {type:"TEXT", constraint:"NOT NULL"},

    # Type du résultat
    # ----------------
    # Pour compléter la donnée précédente le type du résultat
    # Bit 1     : Type de document 0:Brainstorming, 1:Document rédigé, 2:Image, etc.
    # BIT 2     : Destinataire (0: pour soi, document de travail, 1: lecteur,
    #             document de vente, etc. ?)
    type_resultat:  {type:"VARCHAR(8)", default:"'"+("0"*8)+"'"},

    # Pages de cours
    # --------------
    # Hash jsonnés définissant les pages de cours à étudier en
    # rapport (ou non) avec l'étape courante.
    pages_cours:    {type:"BLOB"},

    # Pages de cours optionnelles, peut-être déjà étudiées mais
    # qu'il peut être intéressant de relire.
    pages_optionnelles: {type:"BLOB"},

    # Exemples
    # --------
    # Exemples de travaux réalisés, le plus souvent tirés de films,
    # même lorsqu'il s'agit de pitch, synopsis, etc.
    # C'est une liste d'identifiants dans la table `exemples`
    exemples:       {type:"BLOB"},

    # Valeur en Points
    # ----------------
    # Nombre de points que rapporte ce travail. Pour savoir si
    # le p-day peut être validé ou non.
    # Noter qu'il ne tient pas compte des points rapportés par
    # les autres sources, comme les questionnaires ou autres
    # questions volantes.
    points:  {type:"INTEGER(3)", constraint:"NOT NULL"},

    # Questionnaires
    # --------------
    # Liste des questionnaires de l'étape (une en général)
    # C'est une liste d'ID correspondant à la table
    #  questionnaires_absolus qui définit ces questionnaires
    questionnaires:  {type:"VARCHAR(255)"},

    # Questions à la volée
    # --------------------
    # Identifiants des questions à la volée qui doivent être posées
    # au cours de cette étape. Ces questions peuvent être posées
    # n'importe quand, au début, en cours ou à la fin d'une session
    # de travail.
    # Il s'agit d'une liste d'identifiants dans la table `flying_qcms`
    # qui sont jsonnés et déjsonnés.
    # Chaque question rapportent un certain nombre de points pour
    # l'auteur en fonction de ses réponses.
    # Noter que des questions peuvent être récurrentes et apparaitre
    # même plusieurs fois au cours d'une étape. Par exemple la question :
    # "Avez-vous travaillé hier ?"
    flying_qcms:    {type:"BLOB"}

  }
end
