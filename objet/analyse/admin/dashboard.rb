# encoding: UTF-8
class FilmAnalyse
class Film

  # Méthode d'helper qui produit la ligne LI pour l'affichage
  # du film.
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


  ORDER_PER_BIT = [0,1,2,3,8,4,5,6,7]
  horder = Hash.new
  ORDER_PER_BIT.each_with_index do |bit, iaff|
    horder.merge!( bit => iaff )
  end
  HORDER_PER_BIT = horder

  # Boutons pour modifier l'état du film
  def boutons_edition
    # Liste des boutons, qui seront rangés dans l'ordre
    # de ORDER_PER_BIT. Cela permet d'avoir un autre ordre
    # d'affichage que celui des bit. Par exemple, le bit 8,
    # qui correspond à analyse complète/simple note se met
    # dans le listing après
    allboutons = Array::new

    # Le dernier chiffre du rang doit correspondre au
    # dernier bit défini dans les :options du film
    (0..8).each do |bit|
      bit_val = options[bit].to_i
      bit_yes = bit_val == 1
      classes_css = ['colvalue']
      # Cas spécial du 3e bit, le type de l'analyse, qui peut être :
      # TM, MYE ou MIX des deux
      tit = if bit == 3
        classes_css << (bit_val == 0 ? 'bgred' : 'bgblue')
        case bit_val
        when 0 then "???"
        when 1 then "TM"
        when 2 then "MYE"
        when 3 then "MIX"
        end
      else
        classes_css << (bit_yes ? 'bgblue' : 'bgred')
        bit_yes ? "O" : "N"
      end

      # On ajoute le bouton à la liste des boutons, à l'endroit
      # voulu par ORDER_PER_BIT ci-dessus
      bouton = tit.in_a(class:classes_css.join(' '), id:"btn_f#{id}-b#{bit}", onclick:"$.proxy(Analyse,'change_bit', #{id}, #{bit})()")
      allboutons[HORDER_PER_BIT[bit]] = bouton
    end
    allboutons.join
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
    case dfilm
    when NilClass
      error "dfilm est nil dans FilmAnalyse::Film.set_data, je ne peux pas dispatcher les valeurs."
    when Hash
      debug "dfilm: #{dfilm.pretty_inspect}"
      dfilm.each { |k, v| instance_variable_set("@#{k}", v) }
    else
      raise "dfilm est de class #{dfilm.class} au lieu d'être un Hash, dans FilmAnalyse::Film.set_data, je ne peux pas dispatcher les valeurs."
    end
  end

end # /Film
end # /FilmAnalyse
