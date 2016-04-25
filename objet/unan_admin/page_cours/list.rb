# encoding: UTF-8
raise_unless_admin

def liste_pages_narration
  pages_narration.collect do |hpage|
    mise_en_forme_page_line(hpage)
  end.join.in_ul(class:'tdm small')
end
def liste_pages_unan
  pages_unan.collect do |hpage|
    mise_en_forme_page_line(hpage)
  end.join.in_ul(class:'tdm small')
end

def mise_en_forme_page_line hpage
  (
    (
      "[edit]".in_a(class:'tiny', target:'_blank', href:"page_cours/#{hpage[:id]}/edit?in=unan_admin") +
      "[voir]".in_a(class:'tiny', target:'_blank', href:"page_cours/#{hpage[:id]}/show?in=unan")
    ).in_div(class:'btns fright') +
   "[#{hpage[:id]}] #{hpage[:titre]}".in_span(title:"#{hpage[:description].purified.strip_tags}")
  ).in_li(class:'tdm', style:'margin-top:8px')
end

def table_pages_cours
  @table_pages_cours ||= Unan::Program::PageCours::table_pages_cours
end
def pages_cours
  @pages_cours ||= begin
    table_pages_cours.select()
  end
end

def dispatch_pages_cours
  @pages_narration  = Array::new
  @pages_unan       = Array::new
  pages_cours.each do |pcid, pcdata|
    if pcdata[:narration_id].nil?
      @pages_unan << pcdata
    else
      @pages_narration << pcdata
    end
  end
end
def pages_narration ; @pages_narration || (dispatch_pages_cours; @pages_narration) end
def pages_unan      ; @pages_unan      || (dispatch_pages_cours; @pages_unan) end
