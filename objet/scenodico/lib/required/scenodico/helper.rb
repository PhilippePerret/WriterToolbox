# encoding: UTF-8
=begin
Extention de la class Scenodico - Méthodes d'helper
=end
class Scenodico

  DATA_ONGLETS = {
    'Accueil'       => "scenodico/home",
    'Dictionnaire'  => "scenodico/list",
    'Recherche'     => "scenodico/search",
    'Proposer'      => "scenodico/proposer"
  }
  class << self

    def titre_h1 sous_titre = nil
      t = "Le Scénodico".in_h1
      t << sous_titre.in_h2 unless sous_titre.nil?
      t << onglets
      t
    end

    def onglets
      @onglets ||= begin
        data_onglets.collect do |onglet_tit, onglet_route|
          classcss = site.current_route?(onglet_route) ? 'active' : nil
          onglet_tit.in_a(href: onglet_route).in_li(class: classcss)
        end.join.in_ul(class:'onglets')
      end
    end

    def data_onglets
      donglets = DATA_ONGLETS
      donglets.merge!("Nouveau" => "scenodico/edit") if user.admin?
      return donglets
    end

  end #/<<self
end #/Filmodico
