# encoding: UTF-8

class Cnarration
  LIVRES = {
    1   => {id:1,   hname: "La Structure", stitre:nil, folder:'structure'},
    2   => {id:2,   hname: "Les Personnages", stitre:nil, folder:'personnages'},
    3   => {id:3,   hname: "La Dynamique narrative", folder:'dynamique', stitre:"Objectifs, Obstacles et Conflits"},
    4   => {id:4,   hname: "La Thématique", folder:'thematique', stitre:nil},
    5   => {id:5,   hname: "Les Documents de travail", folder:'documents', stitre:"Les documents indispensables de l'auteur"},
    6   => {id:6,   hname: "Le Travail de l'auteur", folder:'travail_auteur', stitre:"L'auteur au quotidien, méthodologie et attitude"},
    7   => {id:7,   hname: "Les Meilleurs procédés narratifs", folder:'procedes', stitre:nil},
    8   => {id:8,   hname: "Les Concepts narratifs utiles", folder:'concepts', stitre:nil},
    9   => {id:9,   hname: "Le Dialogue", folder:'dialogue', stitre:nil},
    10  => {id:10,  hname: "L'Analyse de films", folder:'analyse', stitre:"Méthodologie d'analyse pour tirer le maximum de sa vision des films"}
  }

  SYM2ID = {
    structure:          1,
    personnages:        2,
    dynamiques:         3,
    thematique:         4,
    documents:          5,
    travail_auteur:     6,
    procedes:           7,
    concepts_narratifs: 8,
    dialogue:           9,
    analyse:            10
  }

end #/Cnarration
