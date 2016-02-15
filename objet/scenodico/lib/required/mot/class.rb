# encoding: UTF-8
=begin
Class Scenodico::Mot
=end
class Scenodico
class Mot
  class << self

    def get mot_id
      mot_id = mot_id.to_i
      @instances ||= Hash::new
      @instances[mot_id] ||= new(mot_id)
    end

    def table
      @table ||= Scenodico::table_mots
    end
  end #/<< self
end #/Mot
end #/Scenodico
