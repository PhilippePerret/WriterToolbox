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
    ).in_div(class: class_css_div, 'data-jp' => data_jp_for_div)
  end

  # Retourne les données JP (Jour-programme) de la ligne courante, qui
  # permettra à javascript de n'afficher que les zones voulus
  # Peut retourner :
  #   - NIL si aucun jour-programme n'est défini
  #   - "pday_deb" Le jour-programme si la fin n'est pas définie
  #   - "pday_deb-pday_fin" si segment programme
  def data_jp_for_div
    pday_deb.nil? && pday_fin.nil? && (return nil)
    d = "#{pday_deb}"
    pday_fin.nil? || d += "-#{pday_fin}"
    return d
  end

  def line_formated
    # debug "items count : #{items.count.inspect}"
    c = (
      jours_programme_formated +
      line
    )
    c =
      if items.count > 0
        c.in_a(onclick: "MapProgramme.toggle(this)", class: 'linep')
      else
        c.in_span(class: 'linep')
      end


    lien_show_in_file +
    pday_as_lien + # seulement si c'est la définition d'un segment/jour
    span_travaux +
    c
  end

  # Le lien pour afficher la ligne dans le fichier PROGRAMME_MAP.TXT
  def lien_show_in_file
    '→o'.in_a(href: "atm://open?url=file://#{UNANProgramme.instance.programme_map_file.expanded_path}&line=#{index}", target: :new, class: 'fright')
  end

  def div_items
    items.collect do |iline|
      iline.output
    end.join("\n").in_div(class: 'items', style: style_div_items)
  end

  def jours_programme_formated
    pday_deb != nil || (return '')
    c = pday_deb.to_i.to_s
    pday_fin.nil? || c << "-#{pday_fin.to_i}"
    c.in_span(class: 'segpday')
  end

  # Class CSS du div principal de l'élément
  def class_css_div
    css = ['linep']
    css << "ret"
    if items.count > 0
      css << 'witems'
    end
    css << type
    return css.join(' ')
  end

  def style_div_items
    retrait > 0 ? 'display:none' : ''
  end

  def span_travaux
    travaux.empty? && (return '')
    travaux_as_liens.in_span(class: 'wks')
  end
  def travaux_as_liens
    travaux.collect do |dw|
      wid = dw[:id]
      data_type = UNANProgramme::TYPES_TRAVAUX[dw[:type]]
      data_type != nil || raise("Le type #{dw[:type]} est inconnu dans UNANProgramme::TYPES_TRAVAUX.")
      titre, href =
        if wid.nil?
          # Pour un nouveau travail, exemple, page, etc.
          ["NEW #{data_type[:hname]}", "#{data_type[:objet]}/edit?in=unan_admin"]
        else
          ["#{data_type[:hname]} ##{wid}", "#{data_type[:objet]}/#{wid}/edit?in=unan_admin"]
        end
      titre.in_a(href: href, target: :new, class: ['lkedit', (wid.nil? ? 'warning' : nil)].compact.join(' '))
    end.join('')
    # /liste travaux
  end

  def pday_as_lien
    pday_deb != nil || (return '')
    href = "abs_pday/#{pday_deb}/edit?in=unan_admin"
    "PDay #{pday_deb.to_i}".in_a(href: href, target: :new, class: 'lkpday lkedit', title: "Éditer le jour-programme ##{pday_deb.to_i}").in_div(class: 'fright')
  end
end
