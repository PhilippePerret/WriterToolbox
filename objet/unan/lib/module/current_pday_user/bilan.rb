# encoding: UTF-8
class User
class CurrentPDay

  # Méthode qui sauve dans la propriété :retards du
  # programme courant la valeur du retard du jour
  def save_retard_program
    arr_retards = (auteur.program.retards || "").split('')
    arr_retards[day] = retard_from_0_to_9
    retards = arr_retards.collect{|r| r.nil? ? '0': r}.join('')
    program.set(retards: retards)
  end


  def analyse_depassements

  end

  # La note générale pour la journée, en fonction de l'état
  # général.
  # Elle est comptée d'après la donnée warnings
  def note_generale
    ((9 - retard_from_0_to_9).to_f * 20 / 9).round(1)
  end
  def note_generale_humaine
    ng = note_generale
    if ng.to_i == ng
      ng.to_i
    else
      ng
    end.to_s + '/20'
  end
  # Retourne la marque (HTML) de progression, en fonction
  # du fait que l'auteur est en progression ou non.
  def mark_progression
    if note_generale == note_generale_veille
      # Constante
      '<span class="blue">=</span>'
    elsif note_generale_veille > note_generale
      # Diminution
      '<span class="red">↓</span>'
    else
      # Progression
      '<span class="green">⇡</span>'
    end
  end
  def note_generale_veille
    @note_generale_veille ||= begin
      if day > 1
        ng = program.retards[day - 1].to_i
        ((9 - ng).to_f * 20 / 9).round(1)
      else
        nil
      end
    end
  end

  # Renvoie l'indice du jour réel, en fonction de la date
  # de début du programme.
  def real_day
    @real_day ||= begin
      (NOW - program.created_at) / 1.day
    end
  end

  # ---------------------------------------------------------------------
  #   Les nombres suivant les listes
  #   (seulement pour simplifier les calculs)
  # ---------------------------------------------------------------------
  def nombre_overrun
    @nombre_overrun ||= uworks_overrun.count
  end
  def nombre_unstarted
    @nombre_unstarted ||= uworks_unstarted.count
  end
  def nombre_new
    @nombre_new ||= uworks_ofday.count
  end
  def nombre_goon
    @nombre_goon ||= uworks_goon.count
  end

  # ---------------------------------------------------------------------
  #   Les nombres par dépassement
  #
  #   Trois nombres qui contiennent le nombre de dépassement
  #   par jour de retard
  #   nombre_un_deux, nombre_trois_quatre, nombre_cinq_six
  # ---------------------------------------------------------------------
  def nombre_cinqsix
    @nombre_cinqsix       ||= warnings[5].count + warnings[6].count
  end
  def nombre_trois_quatre
    @nombre_trois_quatre  ||= warnings[3].count + warnings[4].count
  end
  def nombre_un_deux
    @nombre_un_deux       ||= warnings[1].count + warnings[2].count
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
      when nombre_cinqsix > 20 then 9
      when nombre_cinqsix > 10 then 8
      when nombre_cinqsix > 0  then 7
      when nombre_trois_quatre > 20 then 6
      when nombre_trois_quatre > 10 then 5
      when nombre_trois_quatre > 0  then 4
      when nombre_un_deux > 20 then 3
      when nombre_un_deux > 10 then 2
      when nombre_un_deux > 0  then 1
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
