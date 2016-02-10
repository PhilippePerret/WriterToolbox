# encoding: UTF-8
class FilmAnalyse
class Film
  class << self

    def get film_id
      film_id = film_id.to_i
      @instances ||= Hash::new
      @instances[film_id] ||= new(film_id)
    end

  end # << self
end #/Film
end #/FilmAnalyse
