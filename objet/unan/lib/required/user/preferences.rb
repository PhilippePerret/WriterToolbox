# encoding: UTF-8
=begin

Extension des instances User pour les préférences

=end
class User
  #
  # # Enregistre la préférence +pref_id+ à la valeur +pref_value+
  # # Cf. User > Preferences.md
  # def preference= pref_id, pref_value = nil
  #   if pref_id.instance_of?(Hash)
  #     pref_value = pref_id.values.first
  #     pref_id    = pref_id.keys.first
  #   end
  #   pref_id = pref_id.to_sym
  #   debug "Préférence `#{pref_id.inspect}` mise à #{pref_value.inspect}"
  #   set_var( "pref_#{pref_id}", pref_value )
  #   @preferences[pref_id] = pref_value
  # end
  #
  # # Enregistre un flot de préférences d'un bloc
  # def preferences= hpreferences
  #   # Modifier les clés pour l'enregistrement dans la table `variables`
  #   hprefs_def = Hash::new
  #   hpreferences.each do |k, v| hprefs_def.merge!("pref_#{k}" => v)
  #   set_vars hprefs_def
  #   @preferences.merge!(hpreferences)
  # end
  #
  # # Retourne la valeur de la préférence d'identifiant +pref_id+
  # # Cf. User > Preferences.md
  # def preference pref_id, default_value = false
  #   @preferences[pref_id] ||= begin
  #     get_var("pref_#{pref_id}", default_value)
  #   end
  # end
  #
  # # Relève toutes les préférences dans la table `variables` et
  # # les consignes dans @preferences
  # # Note : RETURN le hash des préférences
  # # Cf. User > Preferences.md
  # def preferences
  #   @preferences = Hash::new
  #   table_variables.select(where: "name LIKE 'pref_%'").values.each do |hpref|
  #     pref_id     = hpref[:name][5..-1].to_sym
  #     pref_value  = var_value_to_real(hpref)
  #     @preferences.merge!(pref_id => pref_value)
  #   end
  #   @preferences
  # end
  #
end #/User
