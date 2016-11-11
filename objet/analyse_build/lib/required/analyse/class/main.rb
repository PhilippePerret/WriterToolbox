# encoding: UTF-8
class AnalyseBuild

  extend MethodesMainObjet

  class << self

    def titre
      @titre ||= 'Chantier d’analyse'
    end

    def data_onglets
      {
        'Accueil' => 'analyse_build/home'
      }
    end

  end #<<self
end #/Analyse
