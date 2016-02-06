# encoding: UTF-8
class Unan
class SujetCible
  
  # Nom humain du sujet-cible (sujet et sous-sujet)
  def human_name format = nil
    @human_name ||= begin
      hn = data_sujet[:hname].dup
      # hn << "::#{data_sub_sujet[:hname]}" if sub_sujet_id != nil
      hn = "#{data_sub_sujet[:hname]}<span class='thin'></span>#{hn.downcase}".in_span(class:'nowrap') if sub_sujet_id != nil
      hn
    end
  end

end #/SujetCible
end #/Unan
