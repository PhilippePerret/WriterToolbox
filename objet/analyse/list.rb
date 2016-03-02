# encoding: UTF-8
=begin
Extension de FilmAnalyse pour l'affichage de la liste des films analysés
=end
class FilmAnalyse
class TDM
  class << self

    def traite type
      new(type).as_ul
    end
  end # /self FilmAnalyse::TDM
  # ---------------------------------------------------------------------
  #   Instance FilmAnalyse::TDM
  # ---------------------------------------------------------------------

  # Type de la table des matières, qui peut être :
  #   :complete     Les films achevés
  #   :en_cours     Les films en cours
  #   :inacheves    Les films non finis
  attr_reader :type

  def initialize type
    @type = type
  end

  def as_ul
    films.collect do |fid, fdata|
      ifilm = FilmAnalyse::Film::get(fid)
      # La class CSS va dépendre du fait que le film est ou non
      # consultable pour l'utilisateur courant.
      if ifilm.consultable?
        ifilm.intitule.in_a(href:"analyse/#{fid}/show").in_li(class:'film')
      else
        ifilm.intitule.in_li(class:'film nonvisu')
      end
    end.join.in_ul(class:'films')
  end

  def films
    @films ||= begin
      flag = case type
      when :complete  then "1______1%"
      when :en_cours  then "1____1%"
      when :inacheves then "1____0_0%"
      end
      FilmAnalyse::table_films.select(where:"options LIKE '#{flag}'", order:"annee DESC")
    end
  end

end #/TDM
end #/FilmAnalyse
