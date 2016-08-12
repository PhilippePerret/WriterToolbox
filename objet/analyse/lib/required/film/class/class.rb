# encoding: UTF-8
class FilmAnalyse
class Film
  class << self

    def get film_ref
      debug "film_ref = #{film_ref.inspect}::#{film_ref.class}"
      if film_ref.instance_of?(Fixnum) || film_ref.numeric?
        film_ref = film_ref.to_i
      end
      @instances ||= Hash.new
      @instances[film_ref] || begin
        if film_ref.instance_of?(String)
          fid = get_id_by_film_id( film_ref )
        else
          fid = film_ref
        end
        ifilm = new(fid)
        @instances[film_ref] = ifilm
        if film_ref.instance_of?(String)
          ifilm.film_id = film_ref.freeze
          @instances[fid] = ifilm
        end
        return ifilm
      end
    end

    # La méthode `get` permet de récupérer le film par
    # son ID fixnum, cette méthode permet de le récupérer
    # par
    def get_id_by_film_id film_id
      fid = FilmAnalyse::table_filmodico.select(where:"film_id = '#{film_id}'", colonnes:[]).keys.first
      raise "Film inconnu : #{film_ref}" if fid.nil?
      return fid
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
