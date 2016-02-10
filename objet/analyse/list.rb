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
      liste_affixes_film.reject{|affilm| options[:out].include?(affilm)}
    elsif options.has_key?(:in)
      liste_affixes_film.select{|affilm| options[:in].include?(affilm)}
    else
      liste_affixes_film
    end
    flist.collect do |affilm|
      
      affilm.in_a(href:"analyse/#{film[:id]}/show").in_li(class:'film', id:"film-#{affilm}")
    end.join.in_ul(id:'films')
  end

  # {Array} Retourne la liste des affixes de films
  def liste_affixes_film
    @liste_affixes_film ||= begin
      Dir["#{folder_films}/*.htm"].collect do |path|
        File.basename( path, File.extname(path) )
      end
    end
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
