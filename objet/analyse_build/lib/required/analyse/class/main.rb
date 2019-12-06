# encoding: UTF-8

site.require_objet 'analyse'
site.require_objet 'filmodico'

class AnalyseBuild

  extend MethodesMainObjet

  class << self

    def titre
      @titre ||= 'L’usine à analyse'
    end

    def data_onglets
      ongs = {
        'Accueil'     => 'analyse_build/home',
        'Déposer'     => 'analyse_build/depot'
      }
      if user.analyste?
        ongs.merge!('Extraire' => 'analyse_build/extract')
      else
        ongs.merge!('Participer' => "analyse/participer")
      end
      if current.film?
        ongs.merge!('Définir brins' => "analyse_build/#{current.film.id}/define_brins")
      end
      ongs.merge!('Aide' => 'analyse/aide')

      return ongs
    end

  end #<<self
end #/Analyse
