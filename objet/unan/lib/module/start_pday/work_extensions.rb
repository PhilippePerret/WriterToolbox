# encoding: UTF-8
=begin
Extension des instances Unan::Program::Work pour le passage
au jour suivant
=end
class Unan
class Program
class Work

  # {String} Retourne le message d'avertissement pour le mail
  # de l'auteur en fonction du niveau d'avertissement
  def message_avertissement
    @message_avertissement ||= begin
      case niveau_avertissement
      when nil then nil
      when 1 then "Léger dépassement de moins de 3 jours."
      when 2 then "Dépassement de près d'une semaine. Attention de ne pas vous laisser distancer."
      when 3 then "Dépassement de près de quinze jours. Vous êtes en train de vous laisser prendre par le temps."
      when 4 then "Dépassement de près qu'un mois. Vous êtes sérieusement en retard."
      when 5 then "Dépassement de plus d'un mois sur ce travail. La situation devient critique."
      when 6 then "Dépassement de plus d'un mois et demi, je pense que vous avez renoncé à faire ce travail…"
      end
    end
  end

  # Retourne le niveau de dépassement du travail depuis :
  # NIL pour aucun dépassement, 1 pour moins de trois jours de
  # dépassement à 6 pour plus d'un mois et demi de dépassement
  def niveau_avertissement
    @niveau_avertissement ||= begin
      case true
      when depassement < 0
        # Aucun dépassement
        nil
      when depassement < 3.days
        # Premier avertissement, lorsque le travail était de la veille
        # ou l'avant-veille
        # Donc jour 1 à 2 supplémentaires
        niveau_avertissement = 1
      when depassement < 7.days
        # Second avertissement, lorsque le travail aurait dû être
        # fait 3 jours avant jusque fin de semaine
        # Donc : jours 3 à 7 supplémentaires
        niveau_avertissement = 2

      when depassement < 15.days
        # 3e avertissement, lorsque le travail devait être fait dans
        # la semaine jusque 15 jours
        # Donc : de jour 8 à jour 15
        # Note : Un mail est également envoyé à l'administration
        niveau_avertissement = 3
      when depassement < 31.days
        # 4e avertissement, lorsque le travail devait être fait dans
        # le mois
        # Donc : de jour 16 à 31
        # Note : Un mail est également envoyé à l'administration
        niveau_avertissement = 4
      when depassement < 47.days
        # 5e avertissement, lorsque le travail n'a pas été fait
        # dans le mois.
        # Donc : de jour 32 à plus
        # Note : Un mail est également envoyé à l'administration
        niveau_avertissement = 5
      else
        # Dernier avertissement. L'alerte maximale a été donnée 15
        # jour auparavant, sans réponse et sans changement, l'auteur
        # est considéré comme démissionnaire, on l'arrête.
        # Donc depuis jours 47
        # Note : Un mail est également envoyé à l'administration
        niveau_avertissement = 6
      end
    end
  end

end #/Work
end #/Program
end #/Unan
