# encoding: UTF-8
=begin

Méthode d'helper pour les travaux d'analyse

=end
class FilmAnalyse
class Travail

  # Méthode pour mettre en forme un travail.
  # C'est particulièrement intéressant dans le sens où aucune propriété
  # ne peut être utilisée seule
  def output options = nil
    c = ""
    c << boutons_editions if user.admin? || user.analyste_chef?
    c << "#{film.titre.in_span(class:'titre').in_span(class:'bold film')}, #{action.downcase} #{cible_pour_action} #{hstate.downcase} par #{analyste.pseudo}"
    return c.in_span(class:'small')
  end

  def boutons_editions
    (
      "[edit]".in_a(href:"admin/travaux?in=analyse&travail_id=#{id}") +
      "[kill]".in_a(href:"admin/#{id}/travaux?in=analyse&op=destroy")
    ).in_div(class:'small btns fright')
  end
end #/Travail
end #/FilmAnalyse
