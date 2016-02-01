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

  # Timestamp du jours suivant
  def next_pday_time
    @next_pday_time ||= last_pday_time + pday_duration
  end

  # Durée d'un jour-programme en fonction du rythme choisi
  # par l'auteur.
  def pday_duration ; @pday_duration ||= Fixnum::DUREE_JOUR * coefficient_duree end

  # Timestamp du jour-programme courant, donc du dernier
  # jour-programme du programme courant. Si aucun pday
  # n'est encore défini, on retourne la date de démarrage
  # du programme courant. Mais normalement, un pday a été
  # créé au démarrage du programme (cf. signup_user.rb)
  def last_pday_time
    @last_pday_time ||= begin
      tm = ( icurrent_pday.nil? ? self.created_at : icurrent_pday.start )
      tm || self.created_at
    end
  end

  # Retourne le jour-programme courant, mais au format
  # d'instance Unan::Program::PDay
  # C'est un raccourci pour la formule `current_pday(:instance)`
  def icurrent_pday ; @icurrent_pday ||= current_pday(:instance) end

end #/Program
end #/Unan
