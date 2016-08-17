# encoding: UTF-8
class LineProgramme

  # = main =
  #
  # Sortie de la ligne (et tous ses items)
  #
  def output
    (
      line_formated +
      div_items
    ).in_div(class: class_css_div)
  end

  def line_formated
    (
      jours_programme_formated +
      line +
      span_travaux
    ).in_a(onclick: "MapProgramme.toggle(this)", class: 'linep')
  end

  def div_items
    items.collect do |iline|
      iline.output
    end.join("\n").in_div(class: 'items', style: style_div_items)
  end

  def jours_programme_formated
    pday_deb != nil || (return '')
    "#{pday_deb.to_i}-#{pday_fin.to_i}".in_span(class: 'segpday')
  end

  # Class CSS du div principal de l'élément
  def class_css_div
    css = ['linep']
    css << "ret"
    debug "LINE #{line} : items : #{self.items.count}"
    items.count > 0 && css << 'witems'
    css << type
    return css.join(' ')
  end

  def style_div_items
    retrait > 0 ? 'display:none' : ''
  end

  def span_travaux
    travaux.empty? && (return '')
    " (#{travaux_as_liens})"
  end
  def travaux_as_liens
    travaux.collect do |dw|
      wid = dw[:id]
      data_type = UNANProgramme::TYPES_TRAVAUX[dw[:type]]
      data_type != nil || raise("Le type #{dw[:type]} est inconnu dans UNANProgramme::TYPES_TRAVAUX.")
      titre, href =
        if wid.nil?
          ["New #{data_type[:hname]}", "#{data_type[:objet]}/edit?in=unan_admin"]
        else
          ["#{data_type[:hname]} ##{wid}", "#{data_type[:objet]}/#{wid}/edit?in=unan_admin"]
        end
      titre.in_a(href: href, target: :new)
    end.pretty_join
    # /liste travaux
  end
end
