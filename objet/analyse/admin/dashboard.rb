# encoding: UTF-8
class FilmAnalyse
class Film

  def as_admin_li
    (
      intitule.in_span(class:'tbl_inner filmvalue') +
      boutons_edition
    ).in_div(
      'id'            => "film-#{id}",
      'class'         => "film",
      'data-id'       => "#{id}",
      'data-options'  => options.ljust(8,'0')
      )
  end

  # Boutons pour modifier l'état du film
  def boutons_edition
    (0..7).collect do |bit|
      bit_yes = options[bit].to_i == 1
      ( bit_yes ? "OUI" : "NON" ).in_a(class:"colvalue #{bit_yes ? 'bgblue' : 'bgred'}", id:"btn_f#{id}-b#{bit}", onclick:"$.proxy(Analyse,'change_bit', #{id}, #{bit})()")
    end.join
  end

  def bouton_analyzed
    btn_name = analyzed? ? "Analysé" : "Non analysé"
    btn_name.in_a(id:"btn_bit1-#{id}", onclick: "$.proxy(Analyse,'set_analyzed', #{id})()" )
  end
  def bouton_kill
    ""
  end
  def bouton_accessibilite
    [["1", "abonnés"]].in_select(name:'', selected: options[0].to_i)
  end

  def set_data dfilm
    debug "dfilm: #{dfilm.pretty_inspect}"
    dfilm.each { |k, v| instance_variable_set("@#{k}", v) }
  end

end # /Film
end # /FilmAnalyse
