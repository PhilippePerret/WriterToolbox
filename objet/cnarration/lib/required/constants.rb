# encoding: UTF-8
=begin
Pour ne télécharger que ce fichier, sans charger tout narration :

  require './objet/cnarration/lib/required/constants.rb'
=end

page.title = "Narration" if (defined?(page))

class Cnarration
  LIVRES = {
    # :nbp_expected définit le nombre de pages escomptés pour le livre
    1   => {id:1,   hname: "La Structure", nbp_expected: 120,
      stitre:"Construire un récit captivant au moyen d'une structure solide, émotionnelle et agilement menée d'un bout à l'autre de vos histoires.", folder:'structure'},
    2   => {id:2,   hname: "Les Personnages", nbp_expected: 120,
      stitre:"Développer des personnages riches, complets et captivants au cœur de vos récits.", folder:'personnages'},
    3   => {id:3,   hname: "La Dynamique narrative", nbp_expected: 100, folder:'dynamique',
      stitre:"Construire des intrigues riches, dynamiques et tendues en maitrisant la triade Objectifs-Obstacles-Conflits."},
    4   => {id:4,   hname: "La Thématique", nbp_expected: 100, folder:'thematique',
      stitre:"Donner de la consistance et de la force au récit en développant leur thématique. Tous les outils pour développer de façon riche, équilibrée et audible ses thèmes."},
    5   => {id:5,   hname: "Les Documents d'écriture", nbp_expected:120, folder:'documents',
      stitre:"Tous les documents utilisés par les auteurs pour concevoir avec aisance leurs récits. Tous les documents à connaitre pour se dire auteur."},
    6   => {id:6,   hname: "Le Travail de l'auteur", nbp_expected: 100, folder:'travail_auteur',
      stitre:"Tout ce qu'il faut savoir sur le quotidien de l'auteur, méthodologie, organisation et attitude."},
    7   => {id:7,   hname: "Les Procédés narratifs", nbp_expected: 100, folder:'procedes',
      stitre: "Comprendre et apprendre à maitriser les procédés narratifs utilisés par les plus grands auteurs."},
    8   => {id:8,   hname: "Les Concepts narratifs en action", nbp_expected: 100, folder:'concepts',
      stitre: "Quand la théorie et la pratique se rejoignent pour aider l'auteur à comprendre et améliorer ses récits."},
    9   => {id:9,   hname: "Le Dialogue", nbp_expected: 100, folder:'dialogue',
      stitre: "Apprendre à écrire le meilleur dialogue possible, efficace, riche et cohérent."},
    10  => {id:10,  hname: "L'Analyse de films", nbp_expected: 100, folder:'analyse',
      stitre:"Apprendre à tirer le maximum de sa vision des films."}
  }

  # Symbole du livre vers son ID
  # Comprend les noms des dossiers
  SYM2ID = {
    analyse:            10,
    concepts_narratifs: 8,
    concepts:           8,
    dialogue:           9,
    documents:          5,
    dynamique:          3,
    personnages:        2,
    procedes:           7,
    structure:          1,
    thematique:         4,
    theorie:            8,
    travail_auteur:     6,
    travail:            6
  }

  NIVEAUX_DEVELOPPEMENT = {
    0 => {hname:"Niveau indéfini"},
    1 => {hname:"Création de la page"},
    3 => {hname:"Esquisse"},
    4 => {hname:"Développée"},
    5 => {hname:"Presque achevée"},
    6 => {hname:"À lire par le lecteur"},
    7 => {hname:"À corriger par le rédacteur"},
    8 => {hname:"Relecture finale"},
    9 => {hname:"Correction finale"},
    'a' => {hname:"Achevée"},
  }
end #/Cnarration
