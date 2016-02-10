# encoding: UTF-8
=begin
Extension de FilmAnalyse pour l'affichage de la liste des films analysés
=end
class FilmAnalyse
class << self

  # Retourne une liste UL des films filtrés par les options
  # +options+
  #   :in     Liste Array des films (affixes) à prendre
  #   :out    OU liste Array des films (affixes) à ne pas prendre
  def films_list options = nil
    options ||= Hash::new
    flist = if options.has_key?(:out)
      liste_data_films.reject{|hfilm| options[:out].include?(hfilm[:sym])}
    elsif options.has_key?(:in)
      liste_data_films.select{|hfilm| options[:in].include?(hfilm[:sym])}
    else
      liste_data_films
    end
    flist.collect do |hfilm|
      "#{hfilm[:titre]} (#{hfilm[:annee]} – #{hfilm[:realisateur]})".in_a(href:"#{folder_films}/#{hfilm[:sym]}.htm", target:'_boa_film_tm_').in_li(class:'film', id:"film-#{hfilm[:id]}")
    end.join.in_ul(id:'films')
  end

  # {Array de Hash} Retourne la liste des films analysés en les
  # prenant dans la table analyse.films
  def liste_data_films
    @liste_data_films ||= begin
      table_films.select(where:"options LIKE '1%'").values
    end
  end

  def liste_all_analyses options = nil
    options ||= Hash::new
    if options[:completed]
      # seulement les analyses terminées
      liste_analyses_completed
    elsif options[:not_completed]
      # Seulement les analyses non terminées
      liste_analyses_not_completed
    else
      # Toutes les analyses
      films_list
    end
  end
  def liste_analyses_completed
    "Analyses terminées".in_h3 +
    films_list(completed: true)
  end
  def liste_analyses_not_completed
    "Analyses en cours".in_h3 +
    films_list(completed: false)
  end

  def liste_analyses_autorized
    "Films autorisés".in_h3 +
    films_list(in:['seven'])
  end

  def liste_analyses_non_autorized
    "Film non autorisés".in_h3 +
    films_list(out:['seven'])
  end

end # << self
end #/FilmAnalyse
