# encoding: UTF-8

class User

  def redirect_after_login
    if true == preference(:bureau_after_login, false)
      redirect_to 'bureau/home?in=unan'
    end
  end


  # Retourne la valeur d'une préférence, qui peut avoir n'importe
  # quel type puisque c'est une “variable” enregistrée dans la
  # table `variable`
  # Note : Les préférences sont toutes fausses par défaut.
  def preference pref_id, default_value = false
    get_var("pref_#{pref_id}", default_value)
  end

end
