# encoding: UTF-8
class FilmAnalyse
class Film

  # Pour l'affichage du titre, avec auteur et année, sauf
  # si non demandé.
  # Note : même si ça peut ressembler à ce qui est affiché dans les
  # pages de cours, cette méthode ne sert que pour les analyses.
  # Par défaut, l'affichage ressemble à celui-ci :
  #     TITRE ([TITRE_FR_ITALIC, ]RÉALISATEUR, ANNÉE)
  def intitule options = nil
    t = titre.in_span(class:'titre')
    par = Array::new
    par << titre_fr.in_span(class:'italic') unless titre_fr.to_s == ""
    par << realisateur
    par << annee
    par = "(#{par.join(', ')})".in_span(class:'tiny discret')
    if user.admin?
      types = Array::new
      types << "TM" if analyse_tm?
      types << "MYE" if analyse_mye?
      par += " [type : #{types.join(' & ')}]".in_span(class:'tiny discret')
    end
    "#{t} #{par}"
  end

end #/Film
end #/FilmAnalyse
