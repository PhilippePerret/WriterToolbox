# encoding: UTF-8
class Unan
class Projet
  class << self

    # {Array} Return la liste des types de projet pour un select
    # (spécialement, pour field_select des form-tools)
    def types_for_select
      @types_for_select ||= TYPES.collect { |tid, tdata| [tid, tdata[:hname] ] }
    end

  end # << self
end #/Projet
end #/Unan
