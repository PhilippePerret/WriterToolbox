# encoding: UTF-8
class Cnarration
class Livre
  class << self

    def get livre_id
      livre_id = livre_id.to_i
      @instances            ||= {}
      @instances[livre_id]  ||= new(livre_id)
    end

    # Retourne un Array des identifiants de la table
    # des matières du livre d'identifiant +livre_id+
    def ids_tdm_of_livre livre_id
      res = Cnarration.table_tdms.get( livre_id, colonnes:[:tdm] )
      res != nil || ( return [] )
      (res[:tdm] || '').split(',').collect{|e|e.to_i}
    end

  end # / << self
end #/Livre
end #/Cnarration
