# encoding: UTF-8
=begin

Pour consulter le programme UN AN UN SCRIPT jour après jour

=end

# Il faut charger tous les modules du programme normal
site.require_objet 'unan'
Unan::require_module 'abs_pday'
Unan::require_module 'abs_work' # WORK !!! NOT PDAY
UnanAdmin::require_module( 'abs_pday' )
UnanAdmin::require_module( 'abs_work' )

# Il faut aussi la feuille de style de show.css du work
page.add_css( Unan::folder + "abs_work/show.css" )

# Le "p-day" courant
def ipday
  @ipday ||= Unan::Program::AbsPDay::get(param(:pday) || 1)
end

class Unan
class DAD # Pour D(ay) A(fter) D(ay)
class << self

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def total_points_upto
    totpoints_hier = 0
    (1..(ipday.id - 1)).each do |ij|
      totpoints_hier += points_of(ij)
    end
    sitoutreussi = "(si tout réussit)".in_span(style:"font-size:0.75em")
    pointsdujour = points_of(ipday.id)
    totpoints = (totpoints_hier + pointsdujour).to_s.in_span(class:'bold')
    pointsdujour = pointsdujour == 0 ? "#{pointsdujour} points".in_span(class:'warning bold') : "#{pointsdujour} points"
    "Total des points #{sitoutreussi} : #{totpoints} = #{totpoints_hier} + #{pointsdujour} ce jour."
  end

  def points_of ij
    @works_per_pday ||= begin
      res = Unan::table_absolute_pdays.select(colonnes:[:works])
      h = {}; res.each do |pid, pdata|
        h.merge! pid => pdata[:works].split.collect{|i| i.to_i}
      end; h
    end
    @points_per_work ||= begin
      h = {}; Unan::table_absolute_works.select(colonnes:[:points]).each do |wid, wdata|
        h.merge! wid => wdata[:points].to_i
      end; h
    end

    # if ij == 1
    #   debug "@works_per_pday : #{@works_per_pday.inspect}"
    #   debug "@points_per_work : #{@points_per_work.inspect}"
    # end

    # Pour calculer le nombre de points max gagnés au cours
    # du jour +ij+
    nb = 0
    (@works_per_pday[ij]||[]).each do |wid|
      nb += @points_per_work[wid]
    end
    debug "ij=#{ij} / nb = #{nb}"
    return nb
  end

  # ---------------------------------------------------------------------
  #   Helper méthods
  # ---------------------------------------------------------------------

  # Formulaire pour choisir un jour précis
  def menu_jours
    (1..366).collect do |ijour|
      ijour_s = ijour.rjust(3,"0")
      "#{ijour_s}".in_option(selected: param(:pday) == "#{ijour}" )
    end.join.in_select(id:"pday", name:"pday", onchange:"this.form.submit()").in_form(action:"")
  end

  def lien_works_map
    "Carte des travaux".in_a(href:'abs_work/map?in=unan_admin', target:'_blank')
  end
  def lien_pdays_map
    "Carte des p-days".in_a(href:'abs_pday/map?in=unan_admin', target:'_blank')
  end
  def checkbox_fenetre_fixe
    "Fenêtre fixe".in_checkbox(checked:true, onchange:"UI.bloquer_la_page(this.checked)",class:'small')
  end

end #/<< self DAD
end #/DAD
end #/Unan


class Unan
class Program
class AbsPDay

  def edit_buttons
    return "" unless user.admin?
    (
      lien_edit("[Edit P-Day #{id}]")
    ).in_div(class:'fright tiny')
  end

end #/AbsPDay
end #/Program
end #/Unan
