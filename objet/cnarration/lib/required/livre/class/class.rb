# encoding: UTF-8
class Cnarration
class Livre
  class << self

    def get livre_id
      livre_id = livre_id.to_i
      @instances ||= Hash::new
      @instances[livre_id] ||= new(livre_id)
    end
    
  end # / << self
end #/Livre
end #/Cnarration
