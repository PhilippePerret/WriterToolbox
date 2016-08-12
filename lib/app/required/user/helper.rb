# encoding: UTF-8
class User

  # Cette méthode surclasse la méthode d'origine
  def htype
    hu = "utilisa#{f_trice}"
    case true
    when admin?         then "administra#{f_trice}"
    when unanunscript?  then "auteur#{f_e} du programme 1A1S"
    when subscribed?    then "#{hu} abonné#{f_e}"
    when identified?    then "#{hu} inscrit#{f_e}"
    when guest?         then "simple utilisateur"
    end
  end

  # Retourne un texte de type "d'utilisatrice abonnée" ou
  # "de simple utilisateur"
  def de_htype
    case true
    when guest? then  "de #{htype}"
    else              "d’#{htype}"
    end
  end

end
