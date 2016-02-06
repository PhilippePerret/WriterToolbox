# encoding: UTF-8
raise_unless user.unanunscript? || user.admin?

Unan::require_module 'abs_pday'
Unan::require_module 'abs_work' # WORK !!! NOT PDAY
if user.admin?
  site.require_objet 'unan_admin'
  UnanAdmin::require_module( 'abs_pday' )
  UnanAdmin::require_module( 'abs_work' )
end

# Il faut aussi la feuille de style de show.css du work
page.add_css( Unan::folder + "abs_work/show.css" )

class Unan
class Program
class AbsPDay

  def edit_buttons
    return "" unless user.admin?
    (
      lien_edit("[Edit P-Day #{id}]")
    ).in_div(class:'right tiny')
  end

end #/AbsPDay
end #/Program
end #/Unan
