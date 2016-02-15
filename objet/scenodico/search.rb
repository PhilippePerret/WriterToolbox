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
      found = Hash::new
      if in_mot?
        drequest = data_search_defaut.merge!(where: "mot LIKE '%#{text_searched}%'")
        ( found.merge! table_mots.select(drequest) )
      end
      if in_definition?
        drequest = data_search_defaut.merge!(where: "definition LIKE '%#{text_searched}%'", colonnes:[:mot, :definition])
        ( found.merge! table_mots.select(drequest) )
      end

      @found = found
      debug found.pretty_inspect
      flash "Recherche de #{text_searched}"
    end

    def resultat_recherche
      return "" if @found.nil?
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
    def mots_trouved_as_ul
      @found.collect do |mid, hmot|
        c = hmot[:mot].in_a(href:"scenodico/#{mid}/show", target:'_new').in_div(class:'mot')
        if in_definition? && hmot[:definition].match(/#{text_searched}/i)
          c << ( hmot[:definition].gsub(/(#{text_searched})/i, '<span class="found">\1</span>') ).in_div(class:'definition')
        end
        c.in_li
      end.join.in_ul(class:'mots')
    end

    def text_searched
      @text_searched ||= param_search[:search].nil_if_empty
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
      raise "Il faut fournir le texte à rechercher !" if text_searched.nil?
      raise "Il faut indiquer où faire la recherche, dans le mot ou la définition, ou les deux !" if !in_mot? && !in_definition?
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
