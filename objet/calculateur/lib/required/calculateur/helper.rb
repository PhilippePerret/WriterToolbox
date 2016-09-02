# encoding: UTF-8
class SttCalculator

  extend MethodesMainObjet

  class << self

    def titre; @titre ||= "Le Calculateur de structure".freeze end
    def data_onglets
      {
        "Calculateur" => 'calculateur/main',
        "Aide"        => 'calculateur/aide'
      }
    end
  end # / << self
end # /SttCalculator
