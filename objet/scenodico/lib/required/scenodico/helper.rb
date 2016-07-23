# encoding: UTF-8
=begin
Extention de la class Scenodico - Méthodes d'helper
=end
class Scenodico

  extend MethodesMainObjets

  DATA_ONGLETS = {
    'Accueil'       => 'scenodico/home',
    'Dictionnaire'  => 'scenodico/list',
    'Quiz'          => 'quiz/10/show?qdbr=biblio',
    'Recherche'     => 'scenodico/search',
    'Proposer'      => 'scenodico/proposer'
  }

  class << self

    def titre ; @titre ||= "Le Scénodico".freeze end

    def data_onglets
      donglets = DATA_ONGLETS
      if user.admin?
        donglets.merge!(
          'Nouveau'     => 'scenodico/edit',
          '[Edit Quiz]' => 'quiz/10/edit?qdbr=biblio'
          )
      end
      return donglets
    end

  end #/<<self
end #/Filmodico
