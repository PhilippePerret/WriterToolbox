# encoding: UTF-8
=begin
Extention de la class Scenodico - Méthodes d'helper
=end
class Scenodico

  extend MethodesMainObjets

  DATA_ONGLETS = {
    'Accueil'       => 'scenodico/home',
    'Dictionnaire'  => 'scenodico/list',
    'Quiz'          => nil,
    'Recherche'     => 'scenodico/search',
    'Proposer'      => 'scenodico/proposer',
    'Tous les Quiz'=> 'scenodico/quiz_list'
  }

  class << self

    def titre ; @titre ||= "Le Scénodico".freeze end

    def data_onglets
      donglets = DATA_ONGLETS
      donglets['Quiz'] = route_last_quiz('show')
      if user.admin?
        donglets.merge!(
          'Nouveau'     => 'scenodico/edit',
          '[Edit Quiz]' => route_last_quiz('edit')
          )
      end
      return donglets
    end

    # Retourne la route qui conduit au dernier quiz sur le
    # scénodico
    def route_last_quiz to = 'show'
      drequest = {
        where: "groupe = 'scenodico'",
        order: 'created_at DESC',
        limit: 1,
        colonnes: []
      }
      id_last = site.dbm_table('quiz_biblio', 'quiz').select(drequest).first[:id]
      "quiz/#{id_last}/#{to}?qdbr=biblio"
    end

  end #/<<self
end #/Filmodico
