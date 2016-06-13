# encoding: UTF-8
class Citation
class Search
class << self

  # = main =
  #
  # Méthode principale appelée lors d'une demande de
  # recherche et retournant la liste des citations trouvées
  #
  def resultat
    check_data || ( return '' )
    "Citations trouvées (#{founds.count})".in_h4 +
    resultats_chiffred +
    founds_as_ul
  end

  # Retourne la liste des citations trouvées en fonction
  # des choix
  def founds_as_ul
    if founds.count == 0
      'Aucune citation correspondant aux critères n’a pu être trouvée.'.in_p(class: 'red')
    else
      founds.collect do |found|
        (
          found[:citation] +
          " (#{found[:auteur]})"
        ).in_a(href: "citation/#{found[:id]}/show", target: :new).in_li(class: 'small')
      end.join('').in_ul(class: '')
    end
  end

  # Retourne le div des résultats en chiffre (nombre de
  # citations, etc.)
  def resultats_chiffred
    (
      "Nombre de citations : #{Citation.table.count} " +
      "/ correspondant aux critères : #{founds.count}"
    ).in_div(class: 'small discret')
  end

  # Return un {Array} des datas ({Hash}) des citations correspondant
  # aux critères de recherche.
  def founds
    @founds ||= begin
      # debug "data_request = #{data_request.pretty_inspect}"
      Citation.table.select(data_request).values
    end
  end

  # Le Hash de donnée pour la requête SELECT
  def data_request
    data_request ||= begin
      where = []
      where << where_in('citation')  if in_citation?
      where << where_in('auteur')    if in_auteur?
      where << where_in('source')    if in_source?
      {
        where:    where.join(' OR '),
        order:    'citation',
        colonnes: [:auteur, :citation],
        nocase:   true
      }
    end
  end

  def where_in prop
    @searched.collect do |mot|
      "( #{prop} LIKE '%#{mot}%' )"
    end.join( all_words? ? ' AND ' : ' OR ')
  end

  def searched;     @searched     end
  def in_citation?; @in_quote     end
  def in_auteur?;   @in_auteur    end
  def in_source?;   @in_source    end
  def all_words?;   @all_words    end

  def check_data
    debug "dquote = #{dquote.inspect}"
    @searched = dquote[:searched].nil_if_empty
    @searched != nil || raise('Il faut définir le texte à rechercher ! :-)')
    @searched.gsub!(/(d|l|qu)['’]/, '\1 ')
    @searched = @searched.split(' ')
    @in_auteur  = dquote[:in_auteur]    == 'on'
    @in_quote   = dquote[:in_citation]  == 'on'
    @in_source  = dquote[:in_source]    == 'on'
    @in_auteur || @in_quote || @in_source || raise('Il faut indiquer dans quoi chercher le texte ! :-)')

    @all_words = dquote[:all_words] == 'on'
  rescue Exception => e
    error e.message
  else
    true
  end
  def dquote
    @dquote ||= param(:squote)
  end

end # << self
end #/Search
end #/Citation
