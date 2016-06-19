# encoding: UTF-8
raise_unless_admin
site.require_objet('cnarration')

# Liste UL des pages narration qui sont utilisées
# dans le programme UN AN UN SCRIPT
def liste_pages_narration
  pages_narration.collect do |hpage|
    mise_en_forme_page_line(hpage)
  end.join.in_ul(class:'tdm small')
end

# Retourne le code HTML de la liste de toutes les
# pages de la collection narration qui NE SONT PAS utilisées
# dans le programme UN AN UN SCRIPT
def liste_pages_narration_hors_programme
  data_request = {
    where:    "options LIKE '1%'",
    colonnes: [:titre, :livre_id],
    order:    "livre_id ASC"
  }
  ul_pages = String::new
  current_livre_id = nil
  # -> MYSQL NARRATION !!!
  Cnarration::table_pages.select(data_request).collect do |pdata|
    # Passage au livre suivant (ou premier)
    if pdata[:livre_id] != current_livre_id
      current_livre_id = pdata[:livre_id]
      titre_livre = Cnarration::LIVRES[current_livre_id][:hname]
      ul_pages << titre_livre.in_h3
    end
    next if narration_id_to_page_programme_id.has_key?( pdata[:id] )
    # Page inutilisée par le programme
    ul_pages << mise_en_forme_page_line_narration(pdata)
  end
  ul_pages.in_ul(class:'tdm small')
end
def narration_id_to_page_programme_id
  @narration_id_to_page_programme_id ||= begin
    h = Hash::new;pages_narration.each do |pcdata|
      h.merge! pcdata[:narration_id] => pcdata[:id]
    end;h
  end
end
def liste_pages_unan
  pages_unan.collect do |hpage|
    mise_en_forme_page_line(hpage)
  end.join.in_ul(class:'tdm small')
end

def mise_en_forme_page_line hpage
  classes_css = ['tdm']
  if hpage[:narration_id]
    # -> MYSQL NARRATION
    dn = Cnarration::table_pages.get(hpage[:narration_id], colonnes: [:options])
    opts = dn[:options]
    if opts[0] == '1'
      debug "Test page #{opts.inspect}"
      # Si c'est une page, on regarde si son niveau de développement
      # est suffisant.
      niveau_developpement_ok = opts[1].to_i(11) >= 8
      niveau_developpement_ok || ( classes_css << 'warning' )
    end
  end
  (
    (
      "[edit]".in_a(class:'tiny', target:'_blank', href:"page_cours/#{hpage[:id]}/edit?in=unan_admin") +
      "[voir]".in_a(class:'tiny', target:'_blank', href:"page_cours/#{hpage[:id]}/show?in=unan")
    ).in_div(class:'btns fright') +
   "[#{hpage[:id]}] #{hpage[:titre]}".in_span(title:"#{hpage[:description].purified.strip_tags}")
  ).in_li(class:classes_css.join(' '), style:'margin-top:8px')
end
def mise_en_forme_page_line_narration hpage
  (
    (
      "[ADD]".in_a(class:'tiny', target:'_blank', href:"page_cours/edit?in=unan_admin&pn=#{hpage[:id]}") +
      "[voir]".in_a(class:'tiny', target:'_blank', href:"page/#{hpage[:id]}/show?in=cnarration")
    ).in_div(class:'btns fright') +
   "[#{hpage[:id]}] #{hpage[:titre]}".in_span
  ).in_li(class:'tdm', style:'margin-top:8px')
end


def table_pages_cours
  @table_pages_cours ||= Unan::Program::PageCours::table_pages_cours
end
def pages_cours
  @pages_cours ||= begin
    table_pages_cours.select
  end
end

def dispatch_pages_cours
  @pages_narration  = Array::new
  @pages_unan       = Array::new
  pages_cours.each do |pcdata|
    if pcdata[:narration_id].nil?
      @pages_unan << pcdata
    else
      @pages_narration << pcdata
    end
  end
end
def pages_narration ; @pages_narration || (dispatch_pages_cours; @pages_narration) end
def pages_unan      ; @pages_unan      || (dispatch_pages_cours; @pages_unan) end
