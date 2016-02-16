# encoding: UTF-8
class Filmodico
  class << self

    # = main =
    #
    # Méthode qui procède à la recherche demandée
    def proceed_search
      search = Search::instance
      search.proceed
      @found = search.found
    end

    def resultat_recherche
      return "" if @found.nil?
      @found
    end

  end #/<< self (Filmodico)

  class Search
    include Singleton

    attr_reader :found

    # = main =
    def proceed

      debug "paramas: #{params.pretty_inspect}"

      check_params_or_raise || return

      # Si une recherche par le texte doit être faite
      films_ids = nil
      where_clause = Array::new
      if sought
        keys = Array::new
        keys += ["titre", "titre_fr"] if in_titre?
        keys << "resume" if in_resume?
        keys += ['realisateur', 'auteurs', 'producteurs', 'acteurs'] if in_people?
        where_clause << "(" + (keys.collect { |k| "#{k} LIKE \"%#{sought}%\"" }.join(' OR ')) + ")"
      end

      if after?
        where_clause << "( annee > #{annee_after} )"
      end
      if before?
        where_clause << "( annee < #{annee_before} )"
      end

      films_ids = nil
      unless where_clause.empty?
        where_clause = where_clause.join(' AND ')
        debug "where_clause: #{where_clause.inspect}"
        hfilms = Filmodico::table_films.select(where:where_clause, colonnes:[:titre, :realisateur, :annee], nocase: true).values
      end

      @found = unless hfilms.nil? || hfilms.empty?
        "Nombre de films trouvés : <strong>#{hfilms.count}</strong>" +
        hfilms.collect do |hfilm|
          hfilm[:titre].in_a(href:"filmodico/#{hfilm[:id]}/show", target:'_new').in_li
        end.join.in_ul
      else
        "Aucun film trouvé répondant à vos critères de recherche."
      end

    end

    def params
      @params ||= param(:filmsearch)
    end

    def sought     ; @sought ||= params[:sought].nil_if_empty end
    def in_titre?  ; @search_in_titre   ||= params[:in_titre] == 'on'   end
    def in_resume? ; @search_in_resume  ||= params[:in_resume] == 'on'  end
    def in_people? ; @search_in_people  ||= params[:in_people] == 'on'  end

    def annee_before
      @annee_before ||= params[:year_before]
    end
    def before?
      @search_films_before ||= params[:films_before] == 'on'
    end
    def annee_after
      @annee_after ||= params[:year_after]
    end
    def after?
      @search_films_after ||= params[:films_after] == 'on'
    end

    def check_params_or_raise
      if sought.nil? && before? == false && after? == false
        raise "Il faut donner le texte à chercher ! (ou faire une recherche sur les années)"
      end
      unless in_titre? || in_resume? || in_people? || before? || after?
        raise "Il faut indiquer où chercher le texte"
      end
    rescue Exception => e
      debug e
      error e.message
    else
      true
    end
  end #/Search
end #/Filmodico


case param(:operation)
when 'proceed_search'
  Filmodico::proceed_search
end
