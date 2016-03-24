# encoding: UTF-8
class Filmodico

  class << self

    DATA_ONGLETS = {
      "Accueil"       => "filmodico/home",
      "Dictionnaire"  => "filmodico/list",
      "Recherche"     => "filmodico/search"
    }
    def titre; @titre ||= "Le Filmodico".freeze end

    def data_onglets
      donglets = Hash::new
      donglets.merge!(DATA_ONGLETS)
      donglets.merge!("Nouveau" => "filmodico/edit") if user.admin?
      donglets
    end
  end #/<< self
end #/Filmodico
