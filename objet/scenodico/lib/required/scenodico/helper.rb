# encoding: UTF-8
=begin
Extention de la class Scenodico - Méthodes d'helper
=end
class Scenodico
  class << self

    def titre_h1 sous_titre = nil
      t = "Le Scénodico".in_h1
      t << sous_titre.in_h2 unless sous_titre.nil?
      t
    end

  end #/<<self
end #/Filmodico
