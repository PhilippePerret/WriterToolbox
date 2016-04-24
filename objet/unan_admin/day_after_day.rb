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
