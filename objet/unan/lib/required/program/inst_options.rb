# encoding: UTF-8
=begin

Méthodes et définitions pour les options

=end
class Unan
class Program

  attr_reader :options

  # BIT 1 (0)     Actif(1) ou Inactif(0)
  def activite
    @activite ||= options[0].to_i
  end
  def inactif?  ; activite == 0 end
  def actif?    ; activite == 1 end

  # BIT 2 (1)     PAUSE
  def pause     ; @pause ||= options[1].to_i end
  def pause?    ; pause == 1 end

  # BIT 3 (2)

  # BIT 4 (3)   SUPPORT OBJET FINAL (roman, film, bd, etc.)
              # 0: non défini, 1:Roman, 2:Film, 3:BD, 4:Livre enfant, 9:Autre
  TYPES_SUPPORT = {
    0 => {id: :undefined, hname:"Indéfini",           value:0},
    1 => {id: :roman,     hname:"Roman",              value:1},
    2 => {id: :film,      hname:"Film de fiction",    value:2},
    3 => {id: :bd,        hname:"B.D.",               value:3},
    4 => {id: :lchild,    hname:"Livre pour enfant",  value:4},
    5 => {id: :docu,      hname:"Documentaire",       value:5},
    9 => {id: :autre,     hname:"Autre",              value:9}
  }
  # {Hash} Retour le type de support du projet
  def type_support
    TYPES_SUPPORT[options[3].to_i]
  end

end #/Program
end #/Unan
