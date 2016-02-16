# encoding: UTF-8
class Filmodico
  class << self

    DATA_ONGLETS = {
      "Accueil"       => "filmodico/home",
      "Dictionnaire"  => "filmodico/list",
      "Recherche"     => "filmodico/search"
    }

    def titre_h1 sous_titre = nil
      t = "Filmodico".in_h1
      t << sous_titre.in_h2 unless sous_titre.nil?
      t << onglets
      t
    end

    def onglets
      data_onglets.collect do |ong_titre, ong_route|
        css = site.current_route?(ong_route) ? 'active' : nil
        ong_titre.in_a(href:ong_route).in_li(class:css)
      end.join.in_ul(class:'onglets')
    end

    def data_onglets
      donglets = Hash::new
      donglets.merge!(DATA_ONGLETS)
      donglets.merge!("Nouveau" => "filmodico/edit") if user.admin?
      donglets
    end
  end #/<< self
end #/Filmodico
