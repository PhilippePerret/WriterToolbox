# encoding: UTF-8
class Facture

  extend MethodesMainObjets

  class << self

    def titre ; @titre ||= "Facture d’auteur".freeze end

    def data_onglets
      @data_onglets ||= {
        "Facture" => 'facture/main',
        "Aide"    => 'facture/aide'
      }
    end

  end # / << self
end #/Facture
