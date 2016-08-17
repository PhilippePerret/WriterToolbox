# encoding: UTF-8
class LineProgramme
  class << self

    def instances; @instances ||= Array.new end
    def << iline
      self.instances << iline
    end
  end #/<< self
end #/LineProgramme
