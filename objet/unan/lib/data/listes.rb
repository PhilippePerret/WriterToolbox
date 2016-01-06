# encoding: UTF-8
=begin
Définition des listes qui servent pour les bits dans les types et
autres options caractérisant les étapes
=end
class Unan
  SUPPORTS_RESULTAT = [
    ['0', "Indéfini"],
    ['1', 'Document'],
    ['2', 'Plan'],
    ['3', 'Image'],
    ['9', 'Autre']
  ]
  DESTINATAIRES = [
    ['0', 'Indéfini'],
    ['1', 'Pour soi'],
    ['2', "Lecteurs proches"],
    ['3', "Producteurs"],
    ['9', "Autre"]
  ]
  NIVEAU_DEVELOPPEMENT = [
    ['0', "Indéfini"],
    ['1', "Simple ébauche"],
    ['3', "Esquisse développée"],
    ['5', "Bien développé"],
    ['6', "Affiné"],
    ['7', "Très affiné"],
    ['8', "Presque parfait"],
    ['9', "Travail abouti"]
  ]
end

class Unan
  class Program

    # Les différents rythmes pour suivre le programme Un An Un Script
    # (en moins ou plus d'une année)
    RYTHMES = {
      1 => {value:1, hname:"très lent"},
      2 => {value:2, hname:"lent"},
      3 => {value:3, hname:"tranquille"},
      4 => {value:4, hname:"modéré"},
      5 => {value:5, hname:"moyen"},
      6 => {value:6, hname:"soutenu"},
      7 => {value:7, hname:"rapide"},
      8 => {value:8, hname:"très rapide"},
      9 => {value:9, hname:"accéléré"}
    }

  end
end
