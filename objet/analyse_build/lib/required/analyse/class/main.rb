# encoding: UTF-8

site.require_objet 'analyse'
site.require_objet 'filmodico'

class AnalyseBuild

  extend MethodesMainObjet

  class << self

    def titre
      @titre ||= 'Chantier d’analyse'
    end

    def data_onglets
      {
        'Accueil' => 'analyse_build/home',
        'Déposer' => 'analyse_build/depot'
      }
    end

  end #<<self
end #/Analyse