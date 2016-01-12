# encoding: UTF-8
=begin

Class Unan::Projet
------------------
Méthodes de classe

=end
class Unan
class Projet
  class << self

    def types_for_select
      @types_for_select ||= TYPES.collect { |tid, tdata| [tid, tdata[:hname] ] }
    end

  end # << self
end #/Projet
end #/Unan
