# encoding: UTF-8

class FilmAnalyse
  class << self
    # Les onglets communs à toutes les pages qui font
    # appel à `titre_h1`
    def data_onglets
      @data_onglets ||= {
        "Accueil"     => 'analyse/home',
        "Analyses"    => 'analyse/list',
        "Participer"  => 'analyse/participer',
        # "Grades"      => 'analyse/grades',
        "Aide"        => 'manuel/home?in=analyse'
      }
    end
  end # << self
end #/FilmAnalyse
