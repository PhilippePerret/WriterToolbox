# encoding: UTF-8
class Unan
class Bureau

  # Les valeurs qu'il faut prendre en compte même si elles ne
  # sont pas définies, ce qui survient lorsque ce sont des
  # cases à cocher décochées. Si elles en sont pas définies, il
  # faut mettre leur valeur à false
  def user_preferences
    @user_preferences ||= {
      bureau_after_login:   false,
      daily_summary:        false,
      pastille_taches:      false
    }
  end

  # = main =
  #
  # Méthode principale, appelée à la soumission du panneau des
  # préférences de bureau.
  #
  # Chaque préférence se trouve définie dans les paramètres par un
  # identifiant commençant par "pref_" il suffit donc de les relever
  # pour les sauver, même s'il y a des ajouts.
  # Certaines valeurs, cependant, doivent être traitées individuellement
  # ou de façon spéciale.
  #
  # Par exemple, pour la redirection après le login, cette valeur
  # est dépendante aussi du réglage du profil.
  def save_preferences
    page.params_cgi.each do |key, val|
      next unless key.to_s.start_with?('pref_')
      key = key[5..-1].to_sym
      def_value =
        case key
        when :rythme      then val.to_i
        when :sharing     then val.to_i
        else
          case val
          when "on" then true
          else val
          end
        end
      user_preferences.merge! key => def_value
      if key == :bureau_after_login
        # Réglage de la redirection après le login
        # Si elle est réglée ici, il faut la régler aussi
        # pour la préférence définie dans le profil.
        if def_value # normalement, c'est forcément le cas
          # Noter qu'on n'a besoin de le faire que dans le cas
          # ou l'utilisateur veut rejoindre son bureau, car
          # le choix :goto_after_login, réglage depuis le
          # profil, est toujours traité avant.
          # Noter que si la valeur est modifié dans le profil,
          # ça change aussi :bureau_after_login s'il est pas
          # réglé sur true.
          user_preferences.merge!( :goto_after_login => '2' )
        end
      end
    end
    user.set_preferences( user_preferences )
    flash "Préférences enregistrées."
  end

  # Cf. l'explication dans home.rb
  def missing_data
    @missing_data ||= begin
      errors = Array::new
      errors << "le partage"  if user.projet.sharing == 0
      errors.pretty_join.nil_if_empty
    end
  end

end #/Bureau
end #/Unan


case param(:operation)
when 'bureau_save_preferences'
  bureau.save_preferences
end
