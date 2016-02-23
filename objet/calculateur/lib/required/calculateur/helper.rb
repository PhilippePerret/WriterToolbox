# encoding: UTF-8
class SttCalculator

  extend MethodesMainObjets

  class << self

    def titre; @titre ||= "Calculateur de structure".freeze end
    def data_onglets
      {
        "Calculateur" => 'calculateur/main',
        "Aide"        => 'calculateur/aide'
      }
    end
  end # / << self
end # /SttCalculator
