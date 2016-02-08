# encoding: UTF-8
class Unan
class Aide
  class << self

    alias :link_to_original :link_to
    def link_to relpath, titre, options = nil
      link_to_original relpath, titre, options
    end
    
  end # /<< self
end #/Aide
end #/Unan
