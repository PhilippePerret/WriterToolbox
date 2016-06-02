# encoding: UTF-8
film_options = JSON::parse(param :film_options)

mess = Array::new
errors = Array::new
film_options.each do |fid, opts|
  fid = fid.to_i
  ifilm = FilmAnalyse::table_films.get(fid)
  unless ifilm.nil?
    # Le film existe
    FilmAnalyse::table_films.update( fid, { options: opts, updated_at: NOW } )
    mess << ifilm[:titre]
  else
    errors << "Impossible de trouver le film ##{fid}"
  end
end

Ajax << {message: "Options des films modifiées (dans #{mess.join(', ')})"}
Ajax << {error: errors.join(', ')} unless errors.empty?
