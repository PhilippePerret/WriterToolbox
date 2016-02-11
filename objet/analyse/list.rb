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
      liste_data_films(options).reject{|hfilm| options[:out].include?(hfilm[:sym])}
    elsif options.has_key?(:in)
      liste_data_films(options).select{|hfilm| options[:in].include?(hfilm[:sym])}
    else
      liste_data_films(options)
    end

    # Liste des films retenus
    # debug "flist: #{flist.pretty_inspect}"

    flist.collect do |hfilm|
      titre = "#{hfilm[:titre]} ("
      titre += "#{hfilm[:titre_fr].in_span(class:'italic')} — " unless hfilm[:titre_fr].nil_if_empty.nil?
      titre += "#{hfilm[:realisateur]}, #{hfilm[:annee]})"
      titre.in_a(href:"#{folder_films}/#{hfilm[:sym]}.htm", target:'_boa_film_tm_').in_li(class:'film', id:"film-#{hfilm[:id]}")
    end.join.in_ul(id:'films', class:'tdm')
  end

  # {Array de Hash} Retourne la liste des films analysés en les
  # prenant dans la table analyse.films
  def liste_data_films options = nil
    debug "options: #{options.inspect}"
    options ||= Hash::new
    opts = ""
    if options[:completed] || options[:not_completed] || options[:lisible] || options[:not_lisible] || options[:analyzed]
      opts << "1"
    else
      opts << "0"
    end

    hfilms = table_films.select(where:"options LIKE '#{opts}%'", colonnes:[:titre, :titre_fr, :annee, :realisateur, :sym, :options]).values
    hfilms.select do |hfilm|
      opts = hfilm[:options]
      opts1 = opts[1].to_i
      if options[:completed] && opts1 == 9
        true
      elsif options[:not_completed] && opts1 != 9
        true
      elsif options[:lisible] && opts1 >= 5
        true
      elsif options[:not_lisible] && opts1 < 5
        true
      else
        false
      end
    end
  end

  def liste_all_analyses options = nil
    options ||= Hash::new
    if options[:completed]
      # seulement les analyses terminées
      liste_analyses_completed
    elsif options[:lisible]
      # seulement les analyses lisibles
      liste_analyses_lisibles
    elsif options[:not_lisible]
      # Seulement les analyses non lisibles
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
  def liste_analyses_lisibles
    "Analyses consultables".in_h3 +
    films_list(lisible: true)
  end
  def liste_analyses_not_completed
    "Analyses en cours".in_h3 +
    films_list(not_lisible: true)
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
