# encoding: UTF-8
class Unan
class Program

  # = main =
  #
  # Fonction principale appelée par le CRON job pour savoir
  # s'il faut passer le programme (l'auteur) au jour-programme
  # suivant, en fonction de son rythme et de son jour-programme
  # courant.
  # NOTE : Cette méthode est appelée TOUTES LES HEUREUS. Donc
  # il faut vérifier s'il faut réellement passer au jour-programme
  # suivant. Note : Le CRON fonctionne toutes les heures pour pouvoir
  # suivre les rythmes exacts programmés. Noter que ça a aussi
  # l'avantage d'envoyer les mails au bon moment.
  def test_if_next_pday
    return if NOW < next_pday_time
    Unan::require_module 'start_pday'
    start_next_pday
  end

  # Timestamp du jours suivant
  def next_pday_time
    @next_pday_time ||= last_pday_time + pday_duration
  end

  # Durée d'un jour-programme en fonction du rythme choisi
  # par l'auteur.
  def pday_duration ; @pday_duration ||= Fixnum::DUREE_JOUR * coefficient_pday end

  # Coefficient de durée du jour-programme
  # @usage : On MULTIPLIE la durée réelle par ce nombre pour
  # obtenir la durée-programme.
  def coefficient_pday ; @coef_pday ||= 5.0 / rythme end

  # Timestamp du jour-programme courant, donc du dernier
  # jour-programme du programme courant. Si aucun pday
  # n'est encore défini, on retourne la date de démarrage
  # du programme courant. Mais normalement, un pday a été
  # créé au démarrage du programme (cf. signup_user.rb)
  def last_pday_time
    @last_pday_time ||= ( icurrent_pday.nil? ? self.created_at : icurrent_pday.start )
  end

  # Retourne le jour-programme courant, mais au format
  # d'instance Unan::Program::PDay
  # C'est un raccourci pour la formule `current_pday(:instance)`
  def icurrent_pday ; @icurrent_pday ||= current_pday(:instance) end

  # {Any} Retourne le jour programme courant au format +as+
  #   :human      Sous la forme "2e jours"
  #   :nombre     Sous la forme `2`
  #   :instance   Instance Unan::Program::PDay
  #
  # NOTE : C'est c'est l'instance qui est demandée et que le
  # jour-programme courant n'est pas défini (premier), la méthode
  # retourne NIL. Dans les autres formats, elle retourne 1 ou
  # "1er jour".
  # NOTE : C'est une `variable` de l'auteur de name :current_pday
  def current_pday as = :nombre # ou :human
    @ijour_actif ||= auteur.get_var(:current_pday, :none)
    # En fonction du type du retour
    case as
    when :instance
      @ijour_actif == :none ? nil : PDay::new(self, @ijour_actif)
    when :human, :humain
      @ijour_actif = 1 if @ijour_actif == :none
      mark = @ijour_actif == 1 ? "er" : "e"
      "#{@ijour_actif}<sup>#{mark}</sup> jour"
    when :nombre, :number
      @ijour_actif == :none ? 1 : @ijour_actif
    else
      @ijour_actif
    end
  end

end #/Program
end #/Unan
