# encoding: UTF-8
class Unan
class Program


  # Démarre le jour-programme suivant
  # Méthode générale qui va faire passer le programme courant
  # du jour courant au jour suivant.
  # Noter que suivant le rythme du programme, cela peut survenir
  # n'importe quand, à n'importe quelle heure.
  def start_next_pday
    StarterPDay::new(self).activer_next_pday
  end


end #/Program
end #/Unan
