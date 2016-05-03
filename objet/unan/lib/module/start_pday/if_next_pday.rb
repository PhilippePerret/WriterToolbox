# encoding: UTF-8
=begin
Extension de Unan::Programm pour voir s'il faut faire passer le
programme au jour suivant.
Appelé par le cron job, toutes les heures
=end
class Unan
class Program

  # = main =
  #
  # Fonction principale appelée par le CRON job pour savoir
  # s'il faut passer le programme courant au jour-programme
  # suivant, en fonction de son rythme et de son jour-programme
  # courant.
  # Note : Cette méthode est appelée TOUTES LES HEURES. Donc
  # il faut vérifier s'il faut réellement passer au jour-programme
  # suivant. Note : Le CRON fonctionne toutes les heures pour pouvoir
  # suivre les rythmes exacts programmés. Noter que ça a aussi
  # l'avantage d'envoyer les mails au bon moment.
  def test_if_next_pday
    if NOW < next_pday_time
      # => Pas l'heure pour passer au jours suivant
      return nil
    else
      # Il est temps pour ce programme de passer au jour suivant
      # Note : Bien laisser cette ligne en dernière ligne car elle
      # retourne la valeur de la méthode (un Hash définissant :errors
      # qui est la liste des erreurs rencontrées éventuellement)
      StarterPDay::new(self).activer_next_pday
    end
  end

  # Timestamp du jour-programme suivant. C'est le temps
  # en seconde où l'auteur courant doit passer au jour-programme
  # suivant, en fonction de son rythme de travail.
  def next_pday_time
    @next_pday_time ||= current_pday_start + pday_duration
  end

  # Durée en seconde d'un jour-programme en fonction du
  # rythme choisi actuellement par l'auteur.
  def pday_duration
    @pday_duration ||= Fixnum::DUREE_JOUR * coefficient_duree
  end

  # Retourne le jour-programme courant, mais au format
  # d'instance Unan::Program::PDay
  # C'est un raccourci pour la formule `current_pday(:instance)`
  # OBSOLETE : NE DOIT PLUS SERVIR
  def icurrent_pday ; @icurrent_pday ||= current_pday(:instance) end

end #/Program
end #/Unan
