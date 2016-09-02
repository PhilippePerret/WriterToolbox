# encoding: UTF-8
class Facture

  extend MethodesMainObjet

  class << self

    def titre ; @titre ||= "La Facture d’auteur".freeze end

    def data_onglets
      @data_onglets ||= {
        "Facture" => 'facture/main',
        "Aide"    => 'facture/aide'
      }
    end

    # Nom du bouton "Calculer"
    # Note : S'il est modifié, il sera automatiquement modifié dans
    # l'aide.
    def button_name_calculer
      @button_name_calculer ||= "Calculer"
    end

    # Le nom du bouton pour mettre en forme
    # Note : S'il est modifié, il sera automatiquement modifié dans
    # l'aide.
    def button_name_mise_en_forme
      @button_name_mise_en_forme ||= "Mettre en forme la facture"
    end

    # Le nom du bouton pour imprimer
    # Note : S'il est modifié, il sera automatiquement modifié dans
    def button_name_print
      @button_name_print ||= "Imprimer"
    end

  end # / << self
end #/Facture
