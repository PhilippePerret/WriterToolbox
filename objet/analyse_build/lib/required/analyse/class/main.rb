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
      ongs = {
        'Accueil'     => 'analyse_build/home',
        'Déposer'     => 'analyse_build/depot',
        'Extraire'    => 'analyse_build/extract'
      }
      if current.film?
        ongs.merge!('Définir brins' => "analyse_build/#{current.film.id}/define_brins")
      end

      return ongs
    end

  end #<<self
end #/Analyse
