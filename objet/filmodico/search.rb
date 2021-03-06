# encoding: UTF-8
class Filmodico
  class << self

    # = main =
    #
    # Méthode qui procède à la recherche demandée
    def proceed_search
      search = Search.instance
      search.proceed
      @found = search.found
    end

    def resultat_recherche
      @found.nil? ? '' : @found
    end

    # Renvoie true si un résultat même vie a été obtenu (pour masquer le
    # formulaire)
    def resultat?
      @has_resultat ||= !@found.nil?
    end

  end #/<< self (Filmodico)

  class Search
    include Singleton

    attr_reader :found

    # = main =
    def proceed

      debug "params: #{params.pretty_inspect}"

      check_params_or_raise || return

      # Si une recherche par le texte doit être faite
      films_ids = nil
      where_clause = Array.new
      if sought
        keys = Array.new
        keys += ["titre"] if in_titre?
        keys += ["titre_fr"] if in_titre_fr?
        keys << "resume" if in_resume?
        keys += ['realisateur', 'auteurs', 'producteurs', 'acteurs'] if in_people?
        where_clause << "(" + (keys.collect { |k| "(#{k} LIKE \"%#{sought}%\" OR #{k} LIKE \"%#{sought.capitalize}%\")" }.join(' OR ')) + ")"
      end

      if after?
        where_clause << "annee > #{annee_after}"
      end
      if before?
        where_clause << "annee < #{annee_before}"
      end

      films_ids = nil
      unless where_clause.empty?
        where_clause = where_clause.join(' AND ')
        # debug "where_clause = #{where_clause}"
        hfilms = Filmodico.table_filmodico.select(where: where_clause, colonnes:[:titre, :realisateur, :annee, :film_id])
      end

      if site.ajax?
        # Si c'est une requête ajax
        menu_films = ([['','Choisir…']]+(hfilms||[]).collect{|hfilm| ["FILM[#{hfilm[:film_id]}]", hfilm[:titre]]}).in_select(id: 'choose_filmodico', onchange:'_ONCHANGE_')
        Ajax << {films: hfilms, menu_films: menu_films}
      else
        # Si c'est une requête "normale"
        @found =
          unless hfilms.nil? || hfilms.empty?
            "Nombre de films trouvés : <strong>#{hfilms.count}</strong>" +
            hfilms.collect do |hfilm|
              hfilm[:titre].in_a(href:"filmodico/#{hfilm[:id]}/show", target:'_blank').in_li
            end.join.in_ul
          else
            "Aucun film trouvé répondant à vos critères de recherche."
          end
      end
    end
    # /proceed

    def params
      @params ||= param(:filmsearch)
    end

    def sought        ; @sought            ||= params[:sought].nil_if_empty end
    def in_titre?     ; @search_in_titre   ||= params[:in_titre]  == 'on'  end
    def in_titre_fr?  ; @search_in_titrefr ||= params[:in_titre_fr]  == 'on'  end
    def in_resume?    ; @search_in_resume  ||= params[:in_resume] == 'on'  end
    def in_people?    ; @search_in_people  ||= params[:in_people] == 'on'  end

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
      unless in_titre? || in_titre_fr? || in_resume? || in_people? || before? || after?
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
