# encoding: UTF-8
class LineProgramme

  # Sortie de la ligne
  def output
    (
      line + span_travaux
    ).in_div(class: class_css_div)
  end

  # Class CSS du div principal de l'élément
  def class_css_div
    css = ['linep']
    css << type
    return css.join(' ')
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
