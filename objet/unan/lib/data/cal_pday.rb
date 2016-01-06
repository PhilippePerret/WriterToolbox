# encoding: UTF-8
=begin

Calendrier absolu

=end
class Unan
class Program
class PDayMap

  # Définition des grandes étapes de travail
  #   :start      Le jour de départ (compris)
  #   :end        Le jour de fin (compris)
  #   :duree      Si :start et :end ne sont pas définis, on peut utiliser
  #               la définition de la durée qui permettra d'agencer les étapes
  #               progressivement
  #   :niveau     Le niveau de cette étape, de 1 (principale, donc grande) à
  #               N (plus petite)
  #   :intitule     Le texte qui sera affiché dans le plan général
  #   :description  La description plus précise de l'étape de travail qui pourra
  #                 apparaitre par exemple quand on cliquera sur l'étape.
  #   :sub          Les sous-étapes de l'étape, au niveau supérieur
  PDAY_MAP = {
    definition_histoire:{
      line:__LINE__,
      duree: 28,
      # start: 1, end: 84, # 1 et 84 ensuite
      niveau: 1,
      titre: "Recherche et choix de l'histoire",
      description: "Cette première longue étape va permettre de choisir et de définir l'histoire",
      cours:"Sont abordées au cours de cette étape les premières notions dramaturgiques qui permettront de choisir et de définir avec le plus de pertinence possible une histoire.",
      sub:{
        brainstorming_sujet:{
          line:__LINE__,
          duree:14,
          # start:1, end:14,
          niveau:2,
          titre:"Brainstorming sur l'histoire",
          description:"Cette première étape de travail va consister à brainstormer autour d'une histoire possible. Pour trouver cette histoire, on en cherchera plusieurs, et l'on s'arrêtera sur le pitch le plus prometteur.",
          cours:"Au niveau du cours, on apprend ce qu'est la <strong>base d'une histoire</strong> et comment la choisir."
        },
        choisir_sujet:{
          line:__LINE__,
          duree:14,
          # start:1, end:14,
          niveau:2,
          titre: "Choix du sujet",
          description: "Cette étape va permettre de choisir le sujet par rapport aux histoires qui se seront dégagées au cours de l'étape de travail précédente."
        }
      }
    },
    ebauche_histoire:{
      line:__LINE__,
      # start:85, end:140,
      duree: 56,
      niveau:1,
      titre:"Brainstormings et première ébauche",
      description:"Au cours de ce premier tour de développement, on va ébaucher la structure, les personnages principaux, la thématique et les fondamentales.",
      cours: "Dans cette étape, on aborde deux aspects importants de la conception d'une histoire : le <strong>brainstorming</strong>, qui permet, pour faire court, de développer son imagination autour d'une histoire, et la façon de définir globalement son histoire, d'en faire une <strong>ébauche intéressante, harmonieuse et fertile</strong>.<br />On approche aussi pour la première fois, au cours de cette étape, l'intégralité de <strong>tous les documents d'auteur</strong> qui permettent de concevoir efficacement une histoire quelle qu'elle soit.",
      sub:{
        tour_1_brainstormings:{
          line:__LINE__,
          duree:28,
          # start:85, end:112,
          niveau:2,
          titre:"Brainstormings (1<sup>er</sup> tour de développement)",
          sub:{
            brainstorming_fondamentales:{
              line:__LINE__,
              duree:7,
              # start: 85, end: 91,
              niveau:3,
              titre:"Brainstorming Fondamentales",
              description:"1<sup>er</sup> tour sur les Fondamentales"
            },
            brainstorming_structure:{
              line:__LINE__,
              duree:7,
              # start: 92, end: 98,
              niveau:3,
              titre:"Brainstorming Structure",
              description:""
            },
            brainstorming_personnages:{
              line:__LINE__,
              duree:7,
              # start:99, end:105,
              niveau:3,
              titre:"Brainstorming Personnages",
              description:""
            },
            brainstorming_thematique:{
              line:__LINE__,
              duree:7,
              # start:106, end:112,
              niveau:3,
              titre:"Brainstorming sur les thèmes",
              description:""
            }
          }
        },
        tour_2_ebauches:{
          line:__LINE__,
          duree:28,
          # start:113, end:140,
          niveau:2,
          titre:"Ébauches (2<sup>e</sup> tour de développement)",
          description:"",
          sub:{
            ebauche_fondamentales:{
              line:__LINE__,
              duree:7,
              # start:113, end:119,
              niveau:3,
              titre:"Ébauche Fondamentales",
              description:"2<sup>e</sup> tour sur les Fondamentales"
            },
            ebauche_structure:{
              line:__LINE__,
              duree:7,
              # start:120, end:126,
              niveau:3,
              titre:"Ébauche Structure",
              description:"2<sup>e</sup> tour sur la Structure"
            },
            ebauche_personnages:{
              line:__LINE__,
              duree:7,
              # start:127, end:133,
              niveau:3,
              titre:"Ébauche personnages",
              description:"2<sup>e</sup> tour sur les personnages"
            },
            ebauche_thematique:{
              line:__LINE__,
              duree:7,
              # start:134, end:140,
              niveau:3,
              titre:"Ébauche thématique",
              description:"2<sup>e</sup> tour sur les thèmes"
            }
          }
        }
      }
    },
    approfondissement_histoire:{
      line:__LINE__,
      duree: 56,
      # start:141, end:196,
      niveau: 1,
      titre:"Approfondissement de l'histoire",
      description:"Ce deuxième tour de développement vise à approfondir",
      cours:"Début d'un triple temps, “Approfondissement, Renforcement et Finalisation” ETC.",
      sub: {
        premiers_appros:{
          line:__LINE__,
          duree:28,
          niveau:2,
          titre:"Premiers approndissements (3<sup>e</sup> tour de développement)",
          description:"",
          sub:{
            appro1_fondamentales:{
              duree:7,
              # start:113, end:119,
              niveau:3,
              titre:"1<sup>er</sup> approf. Fondamentales",
              description:"2<sup>e</sup> tour sur les Fondamentales"
            },
            appro1_structure:{
              duree:7,
              # start:120, end:126,
              niveau:3,
              titre:"1<sup>er</sup> approf. Structure",
              description:"2<sup>e</sup> tour sur la Structure"
            },
            appro1_personnages:{
              duree:7,
              # start:127, end:133,
              niveau:3,
              titre:"1<sup>er</sup> approf. Personnages",
              description:"2<sup>e</sup> tour sur les personnages"
            },
            appro1_thematique:{
              duree:7,
              # start:134, end:140,
              niveau:3,
              titre:"1<sup>er</sup> approf. Thématique",
              description:"1<sup>er</sup> tour sur les thèmes"
            }
          }
        },
        seconds_appros:{
          line:__LINE__,
          duree:28,
          niveau:2,
          titre:"Seconds approfondissements (4<sup>e</sup> tour de développement)",
          description:"",
          sub:{
            appro2_fondamentales:{
              line:__LINE__,
              duree:7,
              # start:113, end:119,
              niveau:3,
              titre:"2<sup>nd</sup> approf. Fondamentales",
              description:"2<sup>e</sup> tour sur les Fondamentales"
            },
            appro2_structure:{
              line:__LINE__,
              duree:7,
              # start:120, end:126,
              niveau:3,
              titre:"2<sup>nd</sup> approf. Structure",
              description:"2<sup>e</sup> tour sur la Structure"
            },
            appro2_personnages:{
              line:__LINE__,
              duree:7,
              # start:127, end:133,
              niveau:3,
              titre:"2<sup>nd</sup> approf. Personnages",
              description:"2<sup>e</sup> tour sur les personnages"
            },
            appro2_thematique:{
              line:__LINE__,
              duree:7,
              # start:134, end:140,
              niveau:3,
              titre:"2<sup>nd</sup> approf. Thématique",
              description:"1<sup>er</sup> tour sur les thèmes"
            }
          }
        }
      }
    },

    #
    # RENFORCEMENT DE L'HISTOIRE
    #
    renforcement_histoire:{
      line:__LINE__,
      duree:56,
      # start:xx, end:xx,
      niveau:1,
      titre:"Renforcement de l'histoire",
      description:"",
      sub:{
        premiers_renforcements:{
          line:__LINE__,
          duree:28,
          niveau:2,
          titre:"Premiers renforcements (5<sup>e</sup> tour de développement)",
          description:"",
          sub:{
            renfo1_fondamentales:{
              duree:7,
              # start:113, end:119,
              niveau:3,
              titre:"1<sup>er</sup> renforc. Fondamentales",
              description:"2<sup>e</sup> tour sur les Fondamentales"
            },
            renfo1_structure:{
              duree:7,
              # start:120, end:126,
              niveau:3,
              titre:"1<sup>er</sup> renforc. Structure",
              description:"2<sup>e</sup> tour sur la Structure"
            },
            renfo1_personnages:{
              duree:7,
              # start:127, end:133,
              niveau:3,
              titre:"1<sup>er</sup> renforc. Personnages",
              description:"2<sup>e</sup> tour sur les personnages"
            },
            renfo1_thematique:{
              duree:7,
              # start:134, end:140,
              niveau:3,
              titre:"1<sup>er</sup> renforc. Thématique",
              description:"1<sup>er</sup> tour sur les thèmes"
            }
          }
        },
        seconds_renforcements:{
          line:__LINE__,
          duree:28,
          niveau:2,
          titre:"Seconds renforcements (6<sup>e</sup> tour de développement)",
          description:"",
          sub:{
            renfo2_fondamentales:{
              duree:7,
              # start:113, end:119,
              niveau:3,
              titre:"2<sup>nd</sup> renforc. Fondamentales",
              description:"2<sup>e</sup> tour sur les Fondamentales"
            },
            renfo2_structure:{
              duree:7,
              # start:120, end:126,
              niveau:3,
              titre:"2<sup>nd</sup> renforc. Structure",
              description:"2<sup>e</sup> tour sur la Structure"
            },
            renfo2_personnages:{
              duree:7,
              # start:127, end:133,
              niveau:3,
              titre:"2<sup>nd</sup> renforc. Personnages",
              description:"2<sup>e</sup> tour sur les personnages"
            },
            renfo2_thematique:{
              duree:7,
              # start:134, end:140,
              niveau:3,
              titre:"2<sup>nd</sup> renforc. Thématique",
              description:"1<sup>er</sup> tour sur les thèmes"
            }
          }
        }
      }
    },

    #
    # PREMIÈRE FINALISATION
    #
    premiere_finalisation_histoire:{
      line:__LINE__,
      duree: 28,
      # start:197, end:266,
      niveau:1,
      titre:"Finalisation de l'histoire",
      description:"Cette première finalisation va permettre verrouiller tous les choix, de finalisation",
      sub:{
        premieres_finalisations:{
          line:__LINE__,
          duree:28,
          niveau:2,
          titre:"Premières finalisations (7<sup>e</sup> tour de développement)",
          description:"",
          sub:{
            final1_fondamentales:{
              line:__LINE__,
              duree:7,
              # start:113, end:119,
              niveau:3,
              titre:"1<sup>ère</sup> final° Fondamentales",
              description:"2<sup>e</sup> tour sur les Fondamentales"
            },
            final1_structure:{
              line:__LINE__,
              duree:7,
              # start:120, end:126,
              niveau:3,
              titre:"1<sup>ère</sup> final° Structure",
              description:"2<sup>e</sup> tour sur la Structure"
            },
            final1_personnages:{
              line:__LINE__,
              duree:7,
              # start:127, end:133,
              niveau:3,
              titre:"1<sup>ère</sup> final° Personnages",
              description:"2<sup>e</sup> tour sur les personnages"
            },
            final1_thematique:{
              line:__LINE__,
              duree:7,
              # start:134, end:140,
              niveau:3,
              titre:"1<sup>ère</sup> final° Thématique",
              description:"1<sup>er</sup> tour sur les thèmes"
            }
          }
        }
      }

    },
    check_pre_cd:{
      line:__LINE__,
      duree:28,
      # start:267, end:294,
      niveau:1,
      titre:"Vérifications pré-scénario",
      description:"Avant d'attaquer le scénario, nous allons procéder à des vérifications qui permettront de valider une dernière fois les choix opérés."
    },

    # V1 DU SCÉNARIO

    scenario_v1:{
      line:__LINE__,
      duree:42,
      # start: 295, end: 322,
      niveau: 1,
      titre: "Version 1 du scénario",
      description: "Il va s'agir maintenant de rédiger la toute première version du scénario.<br />En parallèle de cette première version, l'auteur sera amené à commencer à établir les autres éléments d'un dossier de scénario complet, à savoir : un pitch, un synopsis et une note d'intention.",
      cours: "Considérant que les aspects dramaturgiques doivent avoir été acquis pour aborder tranquillement la rédaction de la toute première version du scénario, on s'intéressera particulièrement dans cette étape à la rédaction proprement dite du scénario.<br />Parallèlement, on se concentrera sur les pitchs, synopsis et autre note d'intention lorsque ces documents sont destinés à être diffusés pour présenter le projet de scénario.",
      sub:{
        scenario_v1_expo:{
          line:__LINE__,
          duree:10,
          # start:xx, end:xx,
          niveau:2,
          titre:"v1 : Exposition",
          description:""
        },
        scenario_v1_developpement:{
          line:__LINE__,
          duree:22,
          # start:xx, end:xx,
          niveau:2,
          titre:"v1 : Développement",
          description:""
        },
        scenario_v1_denouement:{
          line:__LINE__,
          duree:10,
          # start:xx, end:xx,
          niveau:2,
          titre: "v1 : Dénouvement",
          description:""
        }
      }
    },

    analyse_v1:{
      line:__LINE__,
      duree:14,
      # start: 323, end: 336,
      niveau:1,
      titre:"Analyse v1 du scénario",
      description:"Dans cette étape, il va s'agir d'analyser la première version établie, de la faire lire et de recueillir les premiers avis.",
      cours: "Savoir estimer son travail est d'une nécessité capitale pour l'auteur. Au cours de cette étape, on apprend à évaluer son script en partant de la première version élaborée. On aborde tous les outils qui permettent de faire une “analyse des symptômes” et un “diagnostique” efficace de son écriture.",
      sub:{

      }
    },

    seconde_finalisation_histoire:{
      line:__LINE__,
      duree: 28,
      # start:197, end:266,
      niveau:1,
      titre:"Seconde finalisation de l'histoire",
      description:"Cette seconde finalisation va permettre de verrouiller tous les choix de finalisation de l'histoire et les mettre en œuvre.<br />En parallèle, on peaufinera un dossier de présentation en affinant la présentation du scénario dans un pitch, un synopsis et une note d'intention.",
      cours: "Savoir estimer son travail est capital, mais apprendre à l'améliorer est tout aussi indispensable. On s'intéresse dans cette étape à l'aspect “Diagnostique & Prescription” de l'écriture, c'est-à-dire à tous les outils qui permettent de comprendre les écueils, de les estimer et de les corriger afin d'améliorer notablement la valeur de son scénario, de façon générale comme dans le détail.",
      sub:{
        secondes_finalisations:{
          line:__LINE__,
          duree:28,
          niveau:2,
          titre:"Secondes finalisations (8<sup>e</sup> tour de développement)",
          description:"",
          sub:{
            final2_fondamentales:{
              line:__LINE__,
              duree:7,
              # start:113, end:119,
              niveau:3,
              titre:"2<sup>nd</sup> final° Fondamentales",
              description:"2<sup>e</sup> tour sur les Fondamentales"
            },
            final2_structure:{
              line:__LINE__,
              duree:7,
              # start:120, end:126,
              niveau:3,
              titre:"2<sup>nd</sup> final° Structure",
              description:"2<sup>e</sup> tour sur la Structure"
            },
            final2_personnages:{
              line:__LINE__,
              duree:7,
              # start:127, end:133,
              niveau:3,
              titre:"2<sup>nd</sup> final° Personnages",
              description:"2<sup>e</sup> tour sur les personnages"
            },
            final2_thematique:{
              line:__LINE__,
              duree:7,
              # start:134, end:140,
              niveau:3,
              titre:"2<sup>nd</sup> final° Thématique",
              description:"1<sup>er</sup> tour sur les thèmes"
            }
          }
        }
      }

    },

    #
    # VERSION 2 DU SCÉNARIO
    #
    scenario_v2:{
      line:__LINE__,
      duree:28,
      # start: 337, end: 364,
      niveau: 1,
      titre: "Version 2 du scénario",
      description: "Premier travail complet de ré-écriture du scénario. Cette étape vise à obtenir la première versions qui pourra être communiquée au “monde”, c'est-à-dire à des lecteurs professionnels tels que des producteurs.",
      cours: "L'aspect pédagogique se concentrera au cours de cette étape de travail sur des points précis et pointus de la narration ainsi que sur la rédaction du scénario lui-même. Seront abordés de nombreux points de finalisation permettant à la ré-écriture d'être efficace.",
      sub:{
        scenario_v2_expo:{
          line:__LINE__,
          duree:7,
          niveau:2,
          titre:"v2 : Exposition",
          description:"Cette étape va se concentrer sur la ré-écriture de l'Exposition de l'histoire, c'est-à-dire sur le premier quart-temps."
        },
        scenario_v2_developpement:{
          line:__LINE__,
          # duree:14,
          start:344, end:357,
          niveau:2,
          titre:"v2 : Développement",
          description:"Cette étape de travail va être consacrée à la ré-écriture du développement de l'histoire."
        },
        scenario_v2_denouement:{
          line:__LINE__,
          duree:7,
          niveau:2,
          titre: "v2 : Dénouement",
          description:"Dans cette dernière étape, on va achever l'écriture finale du dénouement."
        }
      }
    } # / scenario v2
  }


end # /PDayMap
end # /Program
end # /Unan
