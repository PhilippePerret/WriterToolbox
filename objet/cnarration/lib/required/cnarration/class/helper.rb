# encoding: UTF-8
class Cnarration

  DATA_ONGLETS = {
    "Accueil" => "cnarration/home",
    "Livres"  => "livre/list?in=cnarration"
  }

  extend MethodesMainObjets

  class << self

    def titre_h1 sous_titre = nil
      t = "Collection Narration".in_h1
      t << sous_titre.in_h2 unless sous_titre.nil?
      t << onglets # Dans MethodesMainObjets
      t
    end

    def data_onglets
      donglets = Hash::new
      donglets.merge!(DATA_ONGLETS)
      if user.admin?
        donglets.merge!(
          "New page"      => "page/edit?in=cnarration",
          "[Aide admin]"  => "admin/aide?in=cnarration",
          "Synchro"       => "cnarration/synchro"
          )
      end
      donglets
    end
  end #/ << self
end #/Cnarration
