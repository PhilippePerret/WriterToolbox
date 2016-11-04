# encoding: UTF-8
=begin
Extension de la class Unan::Program::Exemple pour les méthodes
d'helper des exemples
=end
class Unan
class Program
class Exemple


  # {String} Sujet humain d'après les options de sujet
  def sujet_humain
    xpl_sujet    = sujet[0].to_i
    xpl_subsujet = sujet[1].to_s # peut être "-" ou un chiffre
    hsujet    = Unan::SujetCible.sujet_hname(xpl_sujet)
    hsujet = hsujet.to_s # au cas où
    unless xpl_subsujet == '-'
      hsujet += " " + Unan::SujetCible::sous_sujet_hname(xpl_sujet, xpl_subsujet)
    end
    hsujet
  end

  def liens_editions
    (
      lien_edit
    ).in_div(class:'small right')
  end
  def lien_show atitre = nil, options = nil
    atitre ||= "Visualiser l'exemple ##{id}"
    options ||= Hash.new
    options.merge!(href: "exemple/#{id}/show?in=unan")
    atitre.in_a(options)
  end

  def lien_edit atitre = nil, options = nil
    atitre ||= "Éditer l'exemple"
    atitre.in_a(href:"exemple/#{id}/edit?in=unan_admin")
  end

end #/Exemple
end #/Program
end #/Unan
