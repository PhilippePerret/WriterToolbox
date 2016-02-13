# encoding: UTF-8
=begin
Extension de FilmAnalyse pour l'affichage de la liste des films analysés
=end
class FilmAnalyse
class << self

  # Retourne une liste UL des films filtrés par les options
  # +options+
  #   Cf. les options de liste_data_films
  #   Options propres à cette méthode :
  #   :no_link    Si true, pas de lien pour voir ces analyses
  #
  def films_list options = nil
    options ||= Hash::new
    class_css = ['tdm']
    class_css << options.delete(:class) if options.has_key?(:class)

    liste_data_films(options).collect do |hfilm|
      titre = "("
      titre += "#{hfilm[:titre_fr].in_span(class:'italic')} — " unless hfilm[:titre_fr].nil_if_empty.nil?
      titre += "#{hfilm[:realisateur]}, #{hfilm[:annee]})"

      titre = "#{hfilm[:titre]} #{titre.in_span(class:'small')}"
      unless options[:no_link]
        titre = titre.in_a(href:"analyse/#{hfilm[:id]}/show", target:'_boa_film_tm_')
      end
      titre.in_li(class:'film', id:"film-#{hfilm[:id]}")
    end.join.in_ul(id:'films', class:class_css.join(' '))
  end

  # {Array de Hash} Retourne la liste des films analysés en les
  # prenant dans la table analyse.films
  # +options+
  #   :completed      Si true, seulement les analyses terminées
  #   :not_completed  Si true, seulement les analyses inachevées
  #   :lisible        Si true, les analyses lisibles (pas terminées mais assez)
  #   :not_lisible    Si true, les analyses non lisibles
  #   :in             Si fourni, c'est une liste d'identifiant ou de sym de films
  #                   qu'on veut prendre parmi ceux retenus.
  #                   Noter qu'il faut des sym String, pas symbole
  #   :out            Si fourni, c'est une liste de syms de films qu'il ne faut
  #                   pas prendre parmi ceux retenus
  #                   Noter qu'il faut des sym String, pas symbole
  def liste_data_films options = nil
    options ||= Hash::new
    opts = ""
    if options[:completed] || options[:not_completed] || options[:lisible] || options[:not_lisible] || options[:analyzed]
      opts << "1"
    else
      opts << "0"
    end

    data_request = Hash::new
    data_request.merge!(colonnes: [:titre, :titre_fr, :annee, :realisateur, :sym, :options])
    if opts != ""
      where_clause = "options LIKE '#{opts}%'"
      data_request.merge!(where: where_clause)
    end

    # Relève des films
    hfilms = table_films.select(data_request).values

    hfilms.select! do |hfilm|
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
      elsif options[:analyzed]
        true
      else
        false
      end
    end

    if options.has_key?(:in)
      hfilms.select!{|hfilm| options[:in].include? hfilm[:sym]}
    end

    if options.has_key?(:out)
      hfilms.reject!{|hfilm| options[:out].include? hfilm[:sym]}
    end

    return hfilms
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

  # Les deux listes quand on n'est pas autorisé
  def liste_analyses_autorized
    div_information_not_subscriber +
    "Films autorisés".in_h3 +
    films_list(lisible:true, in:['seven'])
  end

  def liste_analyses_non_autorized
    "Film non autorisés".in_h3 +
    films_list(analyzed:true, out:['seven'], no_link:true, class:'discret') +
    "".in_div(style:'clear:both')
  end

  def div_information_not_subscriber
    "Seuls les abonnés au site ont la possibilité de consulter l'intégralité des analyses. Si vous le désirez, vous pouvez #{lien.subscribe('vous abonner', class:'bold')} pour #{site.tarif_humain} par an soit #{site.tarif_humain_par_mois}.".in_div(class:'small italic border encart_droit')
  end

end # << self
end #/FilmAnalyse
