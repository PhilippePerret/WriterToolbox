# encoding: UTF-8
=begin
Extension des instances Unan::Program::Work pour le passage
au jour suivant
=end
class Unan
class Program
class Alerts
class << self

  # {String} Retourne le message d'avertissement pour le mail
  # de l'auteur en fonction du niveau d'avertissement
  def message_alerte_depassement
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

  # Retourne le NIVEAU D'ALERTE DE DÉPASSEMENT du travail depuis :
  # NIL pour aucun dépassement, à 6 pour plus d'un mois et
  # demi de dépassement
  # +depassement+ {Fixnum} Le nombre de jours de dépassements
  # ou NIL s'il n'y en a pas.
  def niveau_alerte_depassement overtime
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
    when overtime.nil?  then nil
    when overtime < 3   then 1
    when overtime < 7   then 2
    when overtime < 15  then 3 # mail admin
    when overtime < 31  then 4 # id.
    when overtime < 47  then 5 # id.
    else 6
    end
  end

end #/<< self
end #/Alerts
end #/Program
end #/Unan
