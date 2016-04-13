# encoding: UTF-8

class User

  # Redirection après l'identification
  #
  # Noter un point important : si un `back_to` a été utilisé pour
  # se rendre à une adresse après l'identification, cette méthode
  # ne sera jamais appelée. Donc il ne faut l'utiliser que pour
  # une redirection et rien d'autre.
  def redirect_after_login
    if true == preference(:bureau_after_login, false)
      debug "[User#redirect_after_login] Redirection vers 'bureau/hom?in=unan'"
      redirect_to 'bureau/home?in=unan'
    else
      debug "[User#redirect_after_login] Aucune redirection"
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
