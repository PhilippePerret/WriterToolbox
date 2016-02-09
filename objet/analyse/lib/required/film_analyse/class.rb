# encoding: UTF-8
class FilmAnalyse
  class << self

    def require_module module_name

    end

    def titre_h1 sous_titre = nil
      "Analyses de films".in_h1 +
      (sous_titre ? sous_titre.in_h2 : "") +
      onglets
    end

    # Les onglets communs à toutes les pages qui font
    # appel à `titre_h1`
    def onglets
      (
        "Accueil".in_a(href:'analyse/home')
      ).in_div(class: 'small right')
    end

  end # << self
end #/FilmAnalyse
