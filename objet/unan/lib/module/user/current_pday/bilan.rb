# encoding: UTF-8
class User
class CurrentPDay

  def analyse_depassements

  end


  # Méthode qui sauve dans la propriété :retards du
  # programme courant la valeur du retard du jour
  def save_retard_program
    arr_retards = (auteur.program.retards || "").split('')
    arr_retards[day] = retard_from_0_to_9
    retards = arr_retards.collect{|r| r.nil? ? '0': r}.join('')
    program.set(retards: retards)
  end


  # Retourne la couleur en fonction du retard général
  # Cette couleur sera appliquée au message général.
  def color_per_retard
    case true
    when retard_from_0_to_9 == 0  then 'blue'
    when retard_from_0_to_9 < 4   then 'paleblue'
    when retard_from_0_to_9 < 7   then 'orange'
    else 'red'
    end
  end

  # FRÉQUENCE DES RETARDS
  #
  # RETURN :rare, :frequent, :accident, :souvent, :systematique
  #
  # S'il y a un problème, est-ce un accident ou l'auteur est-il
  # coutumier du fait ? Compter le nombre de fois où
  # l'auteur est passé au même niveau ou au-dessus pour
  # déterminer le pourcentage de retard
  #
  # Noter que ça peut être également un accident de n'avoir
  # aucun retard ;-) si l'auteur en a toujours eu.
  #
  # Cette procédure n'est faite que si l'auteur est
  # depuis plus d'un mois dans son programme. Elle est inutile
  # avant car ça produirait des résultats aberrants comme, par
  # exemple, des valeurs de 100% lorsqu'il n'a qu'un jour de
  # programme dans les pattes.
  #
  def frequence_retard
    return nil if day < 31 || retard_from_0_to_9 == 0

    nombre_retards_egal_ou_sup = 0
    nombre_retards = program.get(:retards).count
    retards.split('').each do |r|
      r = r.to_i
      nombre_retards_egal_ou_sup += 0 if r >= retard_from_0_to_9
    end

    pct_retards_egaux_ou_sup = ((nombre_retards_egal_ou_sup.to_f / nombre_retards) * 100).to_i

    case true
    when pct_retards_egaux_ou_sup < 10  then :accident
    when pct_retards_egaux_ou_sup < 30  then :rare
    when pct_retards_egaux_ou_sup < 50  then :frequent
    when pct_retards_egaux_ou_sup < 70  then :souvent
    else :systematique
    end
  end

  # Le retard de l'auteur, exprimé en un seul chiffre,
  # pour l'enregistrement dans sa propriété :retards de son
  # programme, pour le jour courant
  def retard_from_0_to_9
    @retard_from_0_to_9 ||= begin
      case true
      when nombre_cisi > 20 then 9
      when nombre_cisi > 10 then 8
      when nombre_cisi > 0  then 7
      when nombre_trqu > 20 then 6
      when nombre_trqu > 10 then 5
      when nombre_trqu > 0  then 4
      when nombre_unde > 20 then 3
      when nombre_unde > 10 then 2
      when nombre_unde > 0  then 1
      else 0
      end
    end
  end

  # Renvoie :debug, :milieu ou :fin en fonction du fait
  # qu'on se trouve au début ou à la fin du programme
  #
  # Cela influe sur le message à envoyer à l'auteur.
  #
  def stade_programme
    @stade_programme ||= begin
      if day < 100
        :debut
      elsif day <= 260
        :milieu
      elsif day > 260
        :fin
      end
    end
  end
end #/CurrentPDay
end #/User
