# encoding: UTF-8
class TUnan
  DUSER = {
    pseudo:     "InscriteUNAN", # pas de chiffres !
    patronyme:  "Inscrite UnanunScript",
    mail:       "boa.inscrite.unan@gmail.com",
    password:   'unessaidesignupunan'
  }
  class << self

    def go_and_identify_inscrite
      go_and_identify(DUSER[:mail], DUSER[:password])
    end

    # Retourne une instance de l'inscrite (utilisable seulement
    # à partir du moment où elle est inscrite)
    def inscrite
      @inscrite ||= begin
        remove_users upto: :all
        create_auteur_unan mail: DUSER[:mail], password: DUSER[:password]
      end
    end
  end #/<<self
end #/TUnan
