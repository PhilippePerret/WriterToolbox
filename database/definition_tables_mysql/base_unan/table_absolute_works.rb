# encoding: UTF-8
=begin

Définition de la table `absolute_works` qui définit précisément tous
les travaux à accomplir pour arriver au bout du scénario.

duree En jour-programme
=end
def schema_table_absolute_works
  <<-MYSQL
CREATE TABLE absolute_works
  (
    id      INTEGER         AUTO_INCREMENT,
    titre   VARCHAR(255)    NOT NULL,
    duree   INTEGER(3)      NOT NULL,

    # TYPE_W (type travail)
    # ---------------------
    # Un nombre de 0 (non défini) à 99 qui définit précisément
    # le type de travail, depuis la production d'un document sur
    # l'histoire jusqu'au remplissage d'un questionnaire en passant
    # par des actions à accomplir.
    # Cf. la liste Unan::Program::AbsWork::TYPES dans le fichier
    # ./data/unan/data/listes.rb
    type_w  INTEGER(2)      NOT NULL,

    # TYPE
    # ----
    # Il est constitué de 16 chiffres/lettres définissant 8 paramètres
    # pour le type du travail.
    #   BIT 1   Mis à 1 si l'item_id est une page de la collection
    #           narration.
    #           NON Ce système ne semble pas être utilisé. item_id doit
    #           toujours être un ID de page de cours UNAN, qui détermine
    #           lui-même si c'est narration ou autre
    #
    #   BIT 2   Inutilisé
    #   BIT 3-4 (narrative_target) Cible principal du travail, à savoir:
    #     1:structure, 2:personnage, 3:dialogue, 4:thematique etc. (ces
    #     nombres sont donnés en pure illustration et ne correspondent
    #     pas à une réalité — cf. le document "Narrative Target")
    #   BIT 5 et BIT 6   (typeP) Le type de projet, entre roman, film, etc.
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
    type  VARCHAR(16)     NOT NULL,

    # TRAVAIL
    # -------
    # L'énoncé du travail.
    travail   TEXT,

    # PARENT
    # ------
    # Identifiant du travail parent, if any.
    parent    INTEGER,

    # PREV_WORK
    # ---------
    # Identifiant du travail précédent (je n'utilise pas encore
    # cette propriété, elle ne servira peut-être à rien).
    prev_work INTEGER,

    # RESULTAT
    # --------
    # Résultat littéraire attendu pour ce travail
    resultat TEXT,

    # TYPE_RESULTAT
    # -------------
    # Le type de résultat attendu pour ce travail
    # Pour compléter la donnée précédente le type du résultat
    # Bit 1     : Type de document 0:Brainstorming, 1:Document rédigé, 2:Image, etc.
    #             3 Action à accomplir
    #             propriété volatile `support`
    # BIT 2     : Destinataire (0: pour soi, document de travail, 1: lecteur,
    #             document de vente, etc. ?)
    #             Propriété volatile `destinataire`
    # BIT 3     : Niveau d'exigence de 0 à 9
    #             Propriété volatile `niveau_dev`
    type_resultat   VARCHAR(8),

    # ITEM_ID
    # -------
    # Si le travail à un item, c'est-à-dire, par exemple,
    # une page de cours ou un questionnaire. C'est l'id dans
    # leur table respective.
    item_id INTEGER,

    # EXEMPLES
    # --------
    # Exemples de travaux réalisés, le plus souvent tirés de films,
    # même lorsqu'il s'agit de pitch, synopsis, etc.
    # C'est une liste d'identifiants dans la table `exemples`
    # Il peut s'agir aussi de screenshots lorsqu'il s'agit de
    # d'action à accomplir.
    # WARNING ! Cette donnée a besoin d'être traitée en lecture
    # pour décomposer le string en array
    exemples VARCHAR(255),


    # PAGES_COURS_IDS
    # ---------------
    # Page de cours associées. Noter qu'elles n'ont rien à voir
    # avec les pages que l'apprenti-auteur doit lire au cours de
    # son programme, elles sont simplement données en aide.
    # Noter également qu'il ne s'agit pas d'ID dans la collection
    # Narration mais d'ID de pages de cours dans le programme UNAN
    # donc d'instance Unan::Program::PageCours (qui peuvent bien
    # entendu faire référence à des pages de Narration)
    pages_cours_ids VARCHAR(255),

    # POINTS
    # ------
    # Nombre de points que rapporte ce travail. Pour savoir si
    # le p-day peut être validé ou non.
    # Noter qu'il ne tient pas compte des points rapportés par
    # les autres sources, comme les questionnaires ou autres
    # questions volantes.
    points INTEGER(3) NOT NULL,

    # UPDATED_AT
    # ----------
    updated_at INTEGER(10),

    # CREATED_AT
    # ----------
    # Date de création de la donnée
    created_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
