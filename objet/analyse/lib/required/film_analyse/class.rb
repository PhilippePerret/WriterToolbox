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
        "Accueil".in_a(href:'analyse/home').in_li         +
        "Analyses".in_a(href:'analyse/list').in_li        +
        "Participer".in_a(href:'analyse/participer').in_li+
        "Grades".in_a(href:'analyse/grades').in_li
      ).in_ul(class: 'small onglets simple')
    end

  end # << self
end #/FilmAnalyse
