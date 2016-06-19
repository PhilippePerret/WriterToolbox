# encoding: UTF-8
class Scenodico
  class << self

    attr_reader :suggested_mot
    attr_reader :proposition_ok

    def proposer_mot
      @suggested_mot = param(:newmot)[:mot].nil_if_empty
      raise "Il faut donner le mot à proposer !" if @suggested_mot.nil?
      check_existence_mot || return
      # Le mot est correct, on peut le proposer
      site.send_mail_to_admin(
        subject:    "Proposition d'un mot pour le scénodico",
        message:    message_proposition_mot,
        formated:  true
      )
      # Message de remerciement
      @proposition_ok = true
    rescue Exception => e
      debug e
      error e.message
    end

    def message_proposition_mot
      <<-HTML
<p>Bonjour administrateur,</p>
<p>#{user.pseudo} propose d'ajouter le mot suivant au Scénodico :</p>
<p class='bold'>#{suggested_mot}</p>
<p>Pour l'ajouter, il suffit de se rendre à l'adresse : </p>
<p>#{site.distant_url}/scenodico/edit</p>
      HTML
    end

    def check_existence_mot
      if table_mots.count(where:"mot = \"#{suggested_mot}\"", nocase:true) > 0
        mot_id = table_mots.select(where:{mot:suggested_mot}, nocase:true, colonnes:[]).first[:id]
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
