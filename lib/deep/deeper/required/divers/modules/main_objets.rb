# encoding: UTF-8
#
# @usage
#   extend MethodesMainObjets
#
module MethodesMainObjets

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------

  # Dans l'objet, définir `titre` (def titre; "<valeur>" end)
  # +options+
  #   :onglets_top    Si true, les onglets sont mis au-dessus du sous-
  #                   titre plutôt que tout en bas
  def titre_h1 sous_titre = nil, options = nil
    options ||= Hash::new
    page.title = titre
    t = titre.in_h1
    t << onglets if options[:onglets_top]
    t << sous_titre.in_h2 unless sous_titre.nil?
    t << onglets unless options[:onglets_top]
    t
  end

  # Dans l'objet, définir la méthode `data_onglets` retournant
  # les données des onglets en fonction du context
  def onglets
    data_onglets.collect do |ong_titre, ong_route|
      css = site.current_route?(ong_route) ? 'active' : nil
      ong_titre.in_a(href:ong_route).in_li(class:css)
    end.join.in_ul(class:'onglets')
  end

end
