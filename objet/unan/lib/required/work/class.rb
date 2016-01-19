# encoding: UTF-8
class Unan
class Program
class Work
  class << self

    def get program, wid
      wid = wid.to_i_inn
      @instances ||= Hash::new
      @instances[wid] ||= new(program, wid)
    end

  end # << self
end #/Work
end #/Program
end #/Unan
