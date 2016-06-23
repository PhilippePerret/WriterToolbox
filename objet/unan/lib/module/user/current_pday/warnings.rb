# encoding: UTF-8
class User
class CurrentPDay

  # AVERTISSEMENTS
  #
  def warnings
    @warnings ||= begin
      h = {
        1 => Array::new(), # Liste de données AbsWork augmentées (*)
        2 => Array::new(),
        3 => Array::new(),
        4 => Array::new(),
        5 => Array::new(),
        6 => Array::new(),
        # Nombre total d'avertissements
        total:              0,
        # Nombre d'avertissements supérieurs à 4, donc
        # d'avertissement graves
        greater_than_four:  0
      }


      # Pour consigner le nombre d'avertissements par niveau en
      # enregistrant les instances travaux dans les listes.
      # Par exemple, la donnée de clé 3 correspond à l'avertissement
      # de niveau 3 et contient dans sa liste tous les travaux qui
      # ont atteint ce niveau d'avertissement
      #
      # (*) Les abs-works augemntés contiennent en plus un
      #     indice de P-Day et un work-id si le travail a
      #     été défini.

      (uworks_overrun + uworks_unstarted).each do |uw|
        niv_alerte = niveau_alerte_per_overrun( uw[:overrun] || uw[:since])
        next if niv_alerte.nil?
        # Travail en dépassement
        h[niv_alerte] << uw
        h[:total]             += 1
        h[:greater_than_four] += 1 if niv_alerte > 4
        message_alerte = message_alerte_depassement(niv_alerte)
        uw.merge!(
          css:            'warning',
          message_alerte: message_alerte
          )
      end

      # Pour le fin du begin, sera porté dans @warnings
      h
    end
  end

  # {String} Retourne le message d'avertissement pour le mail
  # de l'auteur en fonction du niveau d'avertissement
  def message_alerte_depassement niv_alert
    case niv_alert
    when nil then nil
    when 1 then "Léger dépassement de moins de 3 jours."
    when 2 then "Dépassement de près d'une semaine. Attention de ne pas vous laisser distancer."
    when 3 then "Dépassement de près de quinze jours. Vous êtes en train de vous laisser prendre par le temps."
    when 4 then "Dépassement de près qu'un mois. Vous êtes sérieusement en retard."
    when 5 then "Dépassement de plus d'un mois sur ce travail. La situation devient critique."
    when 6 then "Dépassement de plus d'un mois et demi, je pense que vous avez renoncé à faire ce travail…"
    end
  end

  # Retourne le NIVEAU D'ALERTE DE DÉPASSEMENT du travail depuis :
  # NIL pour aucun dépassement jusqu'à 6 pour plus d'un mois et
  # demi de dépassement
  # +orun+ {Fixnum} Le nombre de jours de dépassements
  # ou NIL s'il n'y en a pas.
  def niveau_alerte_per_overrun orun
    # Premier avertissement, lorsque le travail était de la veille
    # ou l'avant-veille
    # Donc jour 1 à 2 supplémentaires
    # Second avertissement, lorsque le travail aurait dû être
    # fait 3 jours avant jusque fin de semaine, donc : jours 3 à 7 supplémentaires
    # 3e avertissement, lorsque le travail devait être fait dans
    # la semaine jusque 15 jours, onc : de jour 8 à jour 15
    # Note : Un mail est également envoyé à l'administration
    # 4e avertissement, lorsque le travail devait être fait dans
    # le mois, donc : de jour 16 à 31 (note : mail administration)
    # 5e avertissement, lorsque le travail n'a pas été fait
    # dans le mois, donc : de jour 32 à plus (mail admin)
    # 6e avertissement. L'alerte maximale a été donnée 15
    # jour auparavant, sans réponse et sans changement, l'auteur
    # est considéré comme démissionnaire, on l'arrête.
    # Donc depuis jours 47
    # Note : Un mail est également envoyé à l'administration
    case true
    when orun.to_i == 0   then nil
    when orun < 3         then 1
    when orun < 7         then 2
    when orun < 15        then 3 # mail admin
    when orun < 31        then 4 # id.
    when orun < 47        then 5 # id.
    else 6
    end
  end

end #/CurrentPDay
end #/User
