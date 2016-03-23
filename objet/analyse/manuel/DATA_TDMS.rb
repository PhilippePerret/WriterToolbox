# encoding: UTF-8
=begin

Data des tables des matières du manuel

=end
DATA_MANUEL_CONSULTATION =  {
  onglet: { # la clé est le nom du sous dossier dans manuel/consulter
    titre: "Onglets",
    items:{
      plan_structurel: {titre:"Onglet “Plan Structurel”"},
      paradigme_field: {titre:"Onglet “Paradigme de Field”"},
      timeline_scenes: {titre:"Onglet “Timeline des scènes”"},
      fondamentales:    {titre:"Onglet “Fondamentales”"},
      scenes:           {titre:"Onglet “Scènes”"},
      diag_drama:       {titre:"Onglet “Diagramme dramatique”"},
      time_sorted:      {titre:"Onglet “Classement par durée”"},
      synopsis:         {titre:"Onglet “Synopsis complet”"},
      personnages:      {titre:"Onglet “Personnages”"},
      brins:            {titre:"Onglet “Brins”"},
      notes:            {titre:"Onglet “Notes”"},
      informations:     {titre:"Onglet “Informations”"},
      procedes:         {titre:"Onglet “Procédés”"},
      qrds:             {titre:"Onglet “Questions dramatiques”"},
      fonctionnement:   {titre:"Fonctionnement"}
    }
  },
  divers:{
    titre: "Divers",
    items:{
      new_window: {titre:"Ouverture dans nouvelle fenêtre"}
    }
  }
}

DATA_MANUEL_REDACTION = {
  analyse: {
    titre: "Analyses",
    items: {
      protocole: {titre:"Protocole d’analyse de film"},
      creation_new_analyse: {titre:"Création d'une nouvelle analyse"}
    }
  },
  collecte: {
    titre: "Collecte",
    items: {
      main_file: {titre:"Fichier principal de collecte"},
      tm_bundle: {titre:"Bundle TextMate sur Mac"},
      tutoriel_textmate: {titre:"Screencast sur le bundle de relève TextMate", smaller:true},
      en_ligne:  {titre:"Collecte en ligne sur le site"},
      tutoriel_en_ligne: {titre:"Screencast sur l'éditeur de collecte en ligne", smaller:true}
    }
  }
}
