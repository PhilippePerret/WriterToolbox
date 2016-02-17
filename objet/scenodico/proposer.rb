# encoding: UTF-8
class Scenodico
  class << self

    attr_reader :suggested_mot

    def proposer_mot
      @suggested_mot = param(:newmot)[:mot].nil_if_empty
      raise "Il faut donner le mot à proposer !" if @suggested_mot.nil?
      check_existence_mot || return

    rescue Exception => e
      debug e
      error e.message
    end

    def check_existence_mot
      if table_mots.count(where:"mot = \"#{suggested_mot}\"", nocase:true) > 0
        mot_id = table_mots.select(where:{mot:suggested_mot}, nocase:true, colonnes:[]).keys.first
        mot_lk = "voir la définition".in_a(href:"scenodico/#{mot_id}/show")
        error "Ce mot existe déjà (#{mot_lk}) !"
      else
        return true
      end
    end

  end # / << self
end #/Scenodico

case param(:operation)
when 'proposer_mot'
  Scenodico::proposer_mot
end
