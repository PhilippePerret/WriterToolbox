# encoding: UTF-8
=begin
Extention de la class Scenodico - Méthodes d'helper
=end
class Scenodico

  extend MethodesMainObjets

  DATA_ONGLETS = {
    'Accueil'       => "scenodico/home",
    'Dictionnaire'  => "scenodico/list",
    'Recherche'     => "scenodico/search",
    'Proposer'      => "scenodico/proposer"
  }
  class << self

    def titre ; @titre ||= "Le Scénodico".freeze end

    def data_onglets
      donglets = DATA_ONGLETS
      donglets.merge!("Nouveau" => "scenodico/edit") if user.admin?
      return donglets
    end

  end #/<<self
end #/Filmodico
