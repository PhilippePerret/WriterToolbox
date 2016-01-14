# encoding: UTF-8
class Unan
class Bureau

  # = main =
  #
  # Méthode principale, appelée à la soumission du panneau des
  # préférences de bureau.
  # Chaque préférence se trouve définie dans les paramètres par un
  # identifiant commençant par "pref_" il suffit donc de les relever
  # pour les sauver, même s'il y a des ajouts.
  # Certaines valeurs, cependant, doivent être traitées individuellement
  # ou de façon spéciale.
  def save_preferences
    # Les valeurs qu'il faut prendre en compte même si elles ne
    # sont pas définies, ce qui survient lorsque ce sont des
    # cases à cocher décochées. Si elles en sont pas définies, il
    # faut mettre leur valeur à false
    prefs = {
      bureau_after_login: false
    }
    page.params_cgi.each do |key, val|
      next unless key.to_s.start_with?('pref_')
      key = key[5..-1].to_sym
      def_value = case key
      when :rythme      then val.to_i
      when :sharing     then val.to_i
      else
        case val
        when "on" then true
        else val
        end
      end
      prefs.merge! key => def_value
    end
    user.set_preferences prefs
    debug "PRÉFÉRENCES SAUVÉES : #{prefs.pretty_inspect}"
    flash "Préférences sauvées"
  end

end #/Bureau
end #/Unan


case param(:operation)
when 'bureau_save_preferences'
  bureau.save_preferences
end
