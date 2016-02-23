# encoding: UTF-8
class FilmAnalyse

  extend MethodesMainObjets

  class << self

    # Requérir un dossier du dossier .objet/analyse/lib/module
    def require_module module_name
      (folder_modules+module_name).require
    end

    def titre; @titre ||= "Analyses de films".freeze end

    # Les onglets communs à toutes les pages qui font
    # appel à `titre_h1`
    def data_onglets
      @data_onglets ||= {
        "Accueil"     => 'analyse/home',
        "Analyses"    => 'analyse/list',
        "Participer"  => 'analyse/participer',
        "Grades"      => 'analyse/grades',
        "Aide"        => 'manuel/home?in=analyse'
      }
    end

  end # << self
end #/FilmAnalyse
