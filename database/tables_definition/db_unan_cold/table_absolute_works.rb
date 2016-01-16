# encoding: UTF-8
=begin

Définition de la table `absolute_works` qui définit précisément tous
les travaux à accomplir pour arriver au bout du scénario.

=end
def schema_table_unan_cold_absolute_works
  @schema_table_unan_absolute_works ||= {

    # ID absolu du travail
    # Correspond à la propriété `work_id` des travaux des auteurs (works)
    id:         {type:"INTEGER",    constraint:"PRIMARY KEY AUTOINCREMENT"},

    # Titre du travail
    # ----------------
    # Un titre générique pour le travail
    # Noter qu'un "jour-programme" possède en général de nombre
    # travaux donc peut avoir plusieurs titres.
    titre:      {type:"VARCHAR(250)", constraint:"NOT NULL"},

    # Jour de départ
    # --------------
    # Le programme-jour (de 1 à 365) où le travail doit être commencé.
    # Pour rappel, des travaux peuvent se chevaucher, donc il est important,
    # pour chaque travail, de préciser son jour départ et sa durée
    pday_start:  {type:"INTEGER(3)", constraint:"NOT NULL"},

    # Durée absolue du travail
    # ------------------------
    # C'est la durée absolue (en programmes-jours) dans laquelle ce
    # travail doit être effectué. Le nombre de jours-réels variera en
    # fonction du `rythme` choisi par l'auteur
    duree:        {type:"INTEGER(3)", constraint:"NOT NULL"},

    # Type de travail
    # ---------------
    # Un nombre de 0 (non défini) à 99 qui définit précisément
    # le type de travail, depuis la production d'un document sur
    # l'histoire jusqu'au remplissage d'un questionnaire en passant
    # par des actions à accomplir.
    # Cf. la liste Unan::Program::AbsWork::TYPES dans le fichier
    # ./data/unan/data/listes.rb
    type_w:   { type:"INTEGER(2)", constraint:"NOT NULL" },

    # Le type
    # ------------------
    # Il est constitué de 16 chiffres/lettres définissant 8 paramètres
    # pour le type du travail.
    #   BIT 1-2   [OBSOLÈTE cf. type_w ci-dessus] (typeW) Le type général,
    #     page de cours à lire, travail
    #     sur la définition de l'histoire, action à accomplir comme créer
    #     des dossiers, etc. C'est un nombre de 0 à 99
    #     Cf. la liste Unan::Program::AbsWork::TYPES
    #   BIT 3-4 (narrative_target) Cible principal du travail, à savoir:
    #     1:structure, 2:personnage, 3:dialogue, 4:thematique etc. (ces
    #     nombres sont donnés en pure illustration et ne correspondent
    #     pas à une réalité — cf. le document "Narrative Target")
    #   BIT 5-6   (typeP) Le type de projet, entre roman, film, etc.
    #     qui peut être visé par ce travail. Ça change principalement
    #     au niveau des termes, par exemple on parlera de "scénario"
    #     pour des films et des BD et de "manuscrit" pour des livres.
    #     Cette donnée permet d'avoir des travaux "jumeaux" en fonction
    #     des types de projets, entendu qu'un auteur travaillant un
    #     roman travaillera sur le manuscrit à la fin alors qu'un auteur
    #     de film travaillera sur le scénario.
    #     Noter que pour le moment seul le premier bit est utilisé. L'autre
    #     est laissé dans lequel cas il faudrait être plus précis
    #     Cf. la liste Unan::Projet::TYPES
    type:       {type:"VARCHAR(16)", constraint:"NOT NULL"},


    # Travail général
    # ---------------
    # La définition générale du travail (TEXT). Il pourra être précisé
    # dans d'autres propriétés
    travail:    {type:"TEXT", constraint:"NOT NULL"},

    # Travail précédent
    # ----------------
    # Lorsque le travail fait suite à un autre, par exemple lorsqu'il
    # faut reprendre le document d'un travail précédent, on l'indique par ce
    # biais
    # Cette donnée est donc fortement liée à la notion de développement en
    # spirale.
    prev_work: {type:'INTEGER(4)', default:"NULL"},

    # Résultat du travail
    # -------------------
    # Le document qui doit être le résultat de ce travail, de façon
    # littéraire (marchera de paire avec la propriété type_resultat)
    resultat:   {type:"TEXT", constraint:"NOT NULL"},

    # Type du résultat
    # ----------------
    # Pour compléter la donnée précédente le type du résultat
    # Bit 1     : Type de document 0:Brainstorming, 1:Document rédigé, 2:Image, etc.
    #             3 Action à accomplir
    #             propriété volatile `support`
    # BIT 2     : Destinataire (0: pour soi, document de travail, 1: lecteur,
    #             document de vente, etc. ?)
    #             Propriété volatile `destinataire`
    # BIT 3     : Niveau d'exigence de 0 à 9
    #             Propriété volatile `niveau_dev`
    type_resultat:  {type:"VARCHAR(8)"},

    # Pour consigner l'ID de l'item suivant le travail,
    # s'il peut en avoir. Par exemple, pour une page de cours, l'id
    # de la page de cours, ou pour un questionnaire, l'id de ce
    # questionnaire, etc.
    item_id: { type:"INTEGER" },

    # Exemples
    # --------
    # Exemples de travaux réalisés, le plus souvent tirés de films,
    # même lorsqu'il s'agit de pitch, synopsis, etc.
    # C'est une liste d'identifiants dans la table `exemples`
    # Il peut s'agir aussi de screenshots lorsqu'il s'agit de
    # d'action à accomplir.
    exemples:       {type:"BLOB"},

    # Valeur en Points
    # ----------------
    # Nombre de points que rapporte ce travail. Pour savoir si
    # le p-day peut être validé ou non.
    # Noter qu'il ne tient pas compte des points rapportés par
    # les autres sources, comme les questionnaires ou autres
    # questions volantes.
    points:  {type:"INTEGER(3)", constraint:"NOT NULL"},

    created_at: {type:"INTEGER(10)",constraint:"NOT NULL"},
    updated_at: {type:"INTEGER(10)",constraint:"NOT NULL"}

  }
end
