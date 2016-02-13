# encoding: UTF-8
class FilmAnalyse
class Film
  class << self

    def get film_id
      film_id = film_id.to_i
      @instances ||= Hash::new
      @instances[film_id] ||= new(film_id)
    end


    # Retourne l'instance FilmAnalyse::Film du film courant
    # Le film courant est défini par la route.
    def current
      @current ||= begin
        get(site.current_route.objet_id)
      end
    end

  end # << self
end #/Film
end #/FilmAnalyse
