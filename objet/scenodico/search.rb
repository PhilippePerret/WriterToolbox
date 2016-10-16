# encoding: UTF-8
class Scenodico
  class << self

    # = main =
    #
    # Méthode qui procède à la recherche
    #
    # Attention : ne pas appeler cette méthode `search`
    # sinon, par l'effet du rest-full, la méthode serait appelée
    # automatiquement puisque la route est "scenodico/search"
    #
    def proceed_search
      check_param_search_or_raise || return
      data_search_defaut = {
        where: nil,
        nocase: true,
        colonnes:[:mot]
      }
      @found = []
      if in_mot?
        drequest = data_search_defaut.merge!(where: "mot LIKE '%#{text_searched}%'", colonnes:[:mot, :definition])
        ( @found += table_mots.select(drequest) )
      end
      if in_definition?
        drequest = data_search_defaut.merge!(where: "definition LIKE '%#{text_searched}%'", colonnes:[:mot, :definition])
        ( @found += table_mots.select(drequest) )
      end

      # On s'arrête là, et c'est la vue, en appelant `resultat_recherche`,
      # qui demandera la construction du résultat. Sauf si on est en ajax,
      # dans lequel cas il faut renvoyer les résultats
      if site.ajax?
        # On fabrique un menu pour en choisir un
        # L'application qui utilise ce moyen doit définir le '_ONCHANGE_' du
        # menu ci-dessous.
        menu_mots = ([['', 'Choisir…']]+@found.collect{|hmot|["MOT[#{hmot[:id]}|#{hmot[:mot].downcase}]", hmot[:mot]]}).in_select(id:'scenodico_found', onchange:'_ONCHANGE_')
        Ajax << {mots: @found, menu_mots: menu_mots}
      end
    end

    def resultat_recherche
      @found != nil || (return '')
      if @found.count > 0
        t = String::new
        t << "Nombre de mots trouvés : #{@found.count.to_s.in_span(class:'bold')}".in_div
        t << mots_trouved_as_ul
      else
        t = "Aucun mot n'a été trouvé avec les critères donnés".in_span(class:'bleu')
      end
      return t
    end

    # Les mots trouvés sous forme d'une liste UL
    # On ajoute les définitions si la recherche devait se faire aussi dans la
    # définition, et on met les mots cherchés en exergue.
    def mots_trouved_as_ul
      @found.collect do |hmot|
        mid = hmot[:id]
        c = hmot[:mot].in_a(href:"scenodico/#{mid}/show", target:'_blank').in_div(class:'mot')
        if in_definition? && hmot[:definition].match(/#{text_searched}/i)
          c << ( hmot[:definition].formate_balises_propres.gsub(/(#{text_searched})/i, '<span class="found">\1</span>') ).in_div(class:'definition')
        end
        c.in_li
      end.join.in_ul(class:'mots')
    end

    def text_searched
      @text_searched ||= begin
        m = param_search[:search]
        m = nil if m.strip == ""
        m
      end
    end
    def in_mot?
      @search_in_mot ||= param_search[:in_mot] == "on"
    end
    def in_definition?
      @search_in_def ||= param_search[:in_def] == 'on'
    end
    def param_search
      @param_search ||= param(:search)
    end


    def check_param_search_or_raise
      text_searched != nil || raise( "Il faut fournir le texte à rechercher !")
      in_mot? || in_definition? || raise( "Il faut indiquer où faire la recherche, dans le mot ou la définition, ou les deux !")
    rescue Exception => e
      debug e
      error e.message
    else
      true
    end

  end #/ << self
end #/Scenodico


case param(:operation)
when 'search_scenodico' then Scenodico::proceed_search
end
