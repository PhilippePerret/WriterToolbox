# encoding: UTF-8
=begin

Noter que ces données servent autant à l'aide pour n'importe quel visiteur que
pour le centre d'aide d'un auteur suivant le programme

=end

DATA_TDM_AIDE = {
  overview: {
    titre: "Aperçu du programme “Un An Un Script”",
    subitems: {
      home:         "Aperçu général du programme"
    }
  },

  fonctionnement:{
    titre:"Fonctionnement du programme “Un An Un Script”",
    subitems: {
      home:         "Accueil",
      general:      "Fonctionnement général d'une année",
      au_quotidien: "Fonctionnement au quotidien",
      bureau:       "Le Centre de travail"
    }
  },
  works:{
    titre:"Les travaux",
    subitems: {
      home:         "Définition générale",
      deal_with:    "S'occuper des travaux",
      types:        "Les types de travaux"
    }
  },
  preferences:{
    titre:"Préférences",
    subitems:{
      tdm:          "Table des matières",
      rythme:       "Réglage du rythme"
    }
  },
  how_to:{
    titre: "Comment faire pour…",
    subitems:{
      marquer_work_fini: "Indiquer qu'un travail est achevé"
    }
  }
}


class Unan
class Aide
  class << self
    def build_tdm
      DATA_TDM_AIDE.collect do |main_folder, data_folder|
        data_folder[:titre].in_li(class:'title') +
        data_folder[:subitems].collect do |sub_folder, titre|
          Unan::Aide::link_to( "#{main_folder}/#{sub_folder}", titre).in_li
          # Noter que c'est une méthode différente en fonction du fait qu'on
          # se trouve dans la section aide elle-même ou dans l'onglet du
          # centre de travail de l'auteur
        end.join
      end.join.in_ul(id:"unan_tdm")
    end
  end #/ << self
end #/Aide
end #/Unan
