# encoding: UTF-8
=begin

Module de calcul d'un questionnaire

=end
class Unan
class Quiz

  # = main =
  #
  # Méthode principale appelée pour procéder au calcul
  # Note : les données se trouvent dans les paramètres, de façon
  # générale dans des paramètres "q-X_r-X" ou des valeurs pour
  # q-X quand ce sont des boutons radio.
  # Par exemple param('q-2') pourra valeur "4" si le choix 4 de
  # la question 2 a été sélectionné.
  def calcule
    # TODO Prendre le nombre de questions (param(:quiz)[:nombre_questions])
    # Est-ce vraiment nécessaire, entendu qu'il faut de toute façon
    # charger le questionnaire pour pouvoir connaitre le nombre de
    # points de chaque question (et il est hors de question de
    # l'inscrire dans le code lui-même)

      # TODO Calculer la valeur de chaque question

    # TODO Enregistrer le score dans le work de l'utilisateur
    # TODO Lui ajouter les points à son total de points (programme)
    # TODO Il faut marquer que l'utilisateur a fait ce questionnaire
    # (donc marquer le travail ended avec la date)

    # TODO Voir en fonction du type de questionnaire ce qu'il faut
    # dire à l'utilisateur. Par exemple, si c'est une simple prise
    # de renseignement, il n'y a rien à faire d'autre que de le remercier.
    # En revanche, si c'est un questionnaire de validation des acquis, à
    # l'opposé, il faut refuser le questionnaire s'il ne comporte pas le
    # nombre de points suffisant (au moins 12 sur 20 ?)
  end

end #/Quiz
end #/Unan
