# encoding: UTF-8
=begin
Extention de Unan::Program::Exemple pour l'affichage de la
liste des exemples
=end
site.require_objet 'unan'
Unan::require_module 'exemple'

class Unan
class Program
class Exemple

  # Helper pour afficher l'exemple
  def as_li
    (
      boutons_edition +
      titre
    ).in_li(class:'li_ex')
  end

  def boutons_edition
    (
      "[edit]".in_a(href:"exemple/#{id}/edit?in=unan_admin") +
      "[show]".in_a(href:"exemple/#{id}/show?in=unan")
    ).in_div(class:'fright tiny')
  end

end #/Exemple
end #/Program
end #/Unan
