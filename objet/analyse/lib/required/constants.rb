# encoding: UTF-8

class FilmAnalyse
  class << self
    # Les onglets communs à toutes les pages qui font
    # appel à `titre_h1`
    def data_onglets
      @data_onglets ||= begin
        h = {
        'Accueil'     => 'analyse/home',
        'Analyses'    => 'analyse/list',
        # "Grades"      => 'analyse/grades',
        'Dépôt'       => 'analyse_build/home',
        'Aide'        => 'manuel/home?in=analyse'
        }
        user.analyste? || user.admin? || h.merge!('Participer' => 'analyse/participer')
        h
      end
    end
  end # << self

  class Travail

    DATA_CIBLES = {
      1 => {hname:'Le film en général', action:"du film en général"},
      2 => {hname:'Le fichier de collecte', action:"du fichier de collecte"},
      3 => {hname:'Un fichier Markdown (texte d’analyse)', action:" du fichier Markdown"},
      4 => {hname:'Un fichier YAML (liste d’éléments)', action:'du fichier'},
      5 => {hname:'Un évènemencier', action:'de l’évènemencier'},
      8 => {hname:'Une image/un graphique', action:'de l’image/graphique'},
      9 => {hname:'Autre document', action:'du document'}

    }

    DATA_PHASES = {
      1 => {hname:"Création du fichier", action:"Création"},
      2 => {hname:"Modification du fichier", action:"Modification"},
      3 => {hname:"Ajouts et suppléments au fichier", action:"ajouts et suppléments"},
      5 => {hname:"Correction du fichier", action:"Correction"},
      9 => {hname:"Finalisation du fichier", action:"Finalisation"}
    }

    DATA_STATES = {
      1 => {hname:"Tout juste défini"},
      2 => {hname:"Initié"},
      3 => {hname:"En cours"},
      7 => {hname:"En pause"},
      8 => {hname:"Achevé"},
      9 => {hname:"Validé"}, # par d'autres analystes plus confirmés
      0 => {hname:"Détruire ce travail"}
    }

  end #/Travail
end #/FilmAnalyse
