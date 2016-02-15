# encoding: UTF-8
class FilmAnalyse
  class << self

    # Requérir un dossier du dossier .objet/analyse/lib/module
    def require_module module_name
      (folder_modules+module_name).require
    end

    def titre_h1 sous_titre = nil
      "Analyses de films".in_h1 +
      (sous_titre ? sous_titre.in_h2 : "") +
      onglets
    end

    # Les onglets communs à toutes les pages qui font
    # appel à `titre_h1`
    def onglets
      onglets = {
        "Accueil"     => 'analyse/home',
        "Analyses"    => 'analyse/list',
        "Participer"  => 'analyse/participer',
        "Grades"      => 'analyse/grades',
        "Aide"        => 'manuel/home?in=analyse'
      }
      onglets.merge!("MON BUREAU" => 'analyse/bureau_perso') if user.analyste?
      onglets.collect do |tit, href|
        tit.in_a(href:href).in_li
      end.join.in_ul(class: 'onglets')

    end

  end # << self
end #/FilmAnalyse
