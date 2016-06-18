# encoding: UTF-8
class Unan
class Program
class Work
  class << self

    # Obtenir un travail
    def get program, wid
      # debug "-> Unan::Program::Work::get (program = #{program.inspect} / wid = #{wid.inspect})"
      wid = wid.to_i_inn
      @instances      ||= {}
      @instances[wid] ||= new(program, wid)
    end

  end # << self
end #/Work
end #/Program
end #/Unan
