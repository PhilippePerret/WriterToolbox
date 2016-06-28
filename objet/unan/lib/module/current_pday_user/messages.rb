# encoding: UTF-8
=begin

  Extension pour les messages et textes


=end
require 'yaml'

class User
class CurrentPDay

  # ---------------------------------------------------------------------
  #   Construction de la section des avertissements (introduction)
  # ---------------------------------------------------------------------
  def avertissements
    if nombre_warnings_serieux > 0
      avertissements_serieux
    elsif nombre_warnings_mineurs > 0
      avertissements_mineurs
    else
      ''
    end
  end

  def avertissements_serieux
    s = nombre_warnings_serieux > 1 ? 's' : ''
    c = "Attention, #{pseudo} vous avez #{nombre_warnings_serieux} alerte#{s} sérieuse#{s} à prendre en compte"
    s = nombre_warnings_mineurs > 1 ? 's' : ''
    c = " (et #{nombre_warnings_mineurs} alerte#{s} mineure#{s})."
    c.in_div(id: 'warning_serieux', class:'warning air')
  end

  # Retourne le code pour les avertissements mineurs.
  # Noter que rien n'est affiché s'il y a des avertissements sérieux
  def avertissements_mineurs
    s = nombre_warnings_mineurs > 1 ? 's' : ''
    # On ne met pas de style rouge dans les 10 premiers jours
    css = day > 9 ? 'warning' : nil
    "Notez, #{pseudo}, que vous avez #{nombre_warnings_mineurs} alerte#{s} mineure#{s}.".in_span(class: css)
  end

  def nombre_warnings
    @nombre_avertissements ||= warnings[:total]
  end
  def nombre_warnings_serieux
    @nombre_avertissements_serieux ||= warnings[:greater_than_four]
  end
  def nombre_warnings_mineurs
    @nombre_avertissements_mineurs ||= nombre_warnings - nombre_warnings_serieux
  end

  def numero_jour_programme
    "<span class='points fright'><span id='jour_programme'>#{day}</span><sup>e</sup></span>Jour-programme :".in_div
  end
  # Indication du jour réel
  #
  # Comme le nombre peut varier d'un en fonction du moment de la
  # journée où on émet le rapport, si le rythme est de 5 et que le
  # jour programme correspond au jour réel d'à peu près 1, les met
  # les deux à la même valeur.
  def numero_jour_reel
    hrealday =
      if rythme == 5 && (real_day + 1 == day)
        real_day + 1
      else
        real_day
      end
    "<span class='points fright'><span id='jour_reel'>#{hrealday}</span><sup>e</sup></span>Jour réel :".in_div
  end
  def nombre_points
    "<span id='nombre_points' class='points fright'>#{program.points}</span><span>Compte actuel de points :</span>".in_div(id:'div_nombre_points')
  end
  # Message contenant la note générale
  #
  # On ne l'indique que si on n'est pas dans les 10
  # premiers jours
  def message_note_generale
    return '' if day < 10
    "<span class='fright'><span id='note_generale' class='points'>#{note_generale_humaine}</span> (#{mark_progression})</span>Note générale du jour précédent : ".in_div
  end

  # Retourne le message principal
  #
  # Ce message est calculé en fonction du nombre-retard et
  # de la fréquence des retards en général. Il est affiché juste
  # au-dessus des fieldsets des listes de travaux et en dessous
  # de l'introduction générale du mail qui donne la tonalité.
  #
  def message_general
    mess = data_messages[retard_from_0_to_9][stade_programme]
    # L'ajout du message de fréquence
    frequence_retard.nil? || mess += data_messages[frequence_retard][stade_programme]

    # On retourne le message après avoir corrigé certaines
    # variables dynamique, à commencer par le pseudo.
    return (mess % {
      pseudo: auteur.pseudo,
      f_ier:  auteur.f_ier
    }).in_div(id:'message_general', class: color_per_retard)

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

  # Grande table contenant les messages en fonction du retard
  # et du fait qu'on se trouve au début, au milieu ou à la fin
  # du programme.
  def data_messages
    @data_messages ||= YAML::load_file(_('texte/messages_retards.yaml'))
  end

end #/CurrentPDay
end #/User
