# encoding: UTF-8
class Unan
class Program
class Exemple
  class << self

    # Obtenir l'instance d'identifiant +edi+ de l'exemple en
    # l'instanciant ou en la prenant dans une instance déjà
    # créée.
    def get eid
      eid = eid.to_i
      @instances      ||= {}
      @instances[eid] ||= new(eid)
    end

  end # << self
end #/Exemple
end #/Program
end #/Unan
