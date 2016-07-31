# encoding: UTF-8
=begin

Class Unan::Program::Cal
------------------------
Gestion du calendrier du programme UN AN pour l'auteur courant

=end
class Unan
class Program
class Cal
  attr_reader :program
  def initialize prog
    @program = prog
  end

  # = main =
  #
  # Méthode principale qui dessine le calendrier dans la page
  # avec le programme dans son intégralité.
  #
  def draw

    # Si on est en offline, on peut définir explicitement
    # certaines valeurs pour pouvoir faire certains essais.
    if OFFLINE
      # Changement volontaire de date de départ pour voir
      # les différentes possibilités
      @start = Time::new(2015, 10, 8).to_i
      # Changement volontaire de rythme pour pouvoir faire des
      # tests d'affichage
      program.instance_variable_set("@rythme", 5)
    end

    # Variable qui contiendra tout le code final
    c = ""
    # Variable qui contiendra le jour du calendrier
    cday = nil

    # On boucle sur chaque jour
    program.nombre_jours.times do |itime|

      cday = cday.nil? ? Day::new( self, start ) : cday.next_day

      # Si c'est le premier jour du mois ou le tout premier jours
      # du programme, il faut passer au mois suivant
      if cday.first_day_of_month? || itime == 0
        # Changement de mois
        c << cday.mois_humain.in_div(class:'month_mark')
        c << div_jours_semaine
        # Il y a un certain nombre de jours vides avant le
        # premier du mois, on les marque.
        nombre_vides_start_mois = cday.wday == 0 ? 6 : cday.wday - 1
        nombre_vides_start_mois.times do |itime|
          c << "&nbsp;".in_div(class: 'calday empty')
        end
      end

      # La classe en fonction du fait que le jour est avant aujourd'hui,
      # aujourd'hui ou après aujourd'hui
      divclass = ['calday']
      divclass << case true
      when cday.today? then 'tod'
      when cday.before_today? then 'beftod'
      when cday.after_today?  then 'afttod'
      end

      # On ajoute le div final
      c << (
        "#{cday.day}".in_span(class:'mday') +
        "&nbsp;".in_span
      ).in_div( class:divclass.join(' ') )
    end
    c.in_div(id:"calendrier")
  end

  # Des raccourcis
  def start   ; @start  ||= program.start   end
  def end     ; @end    ||= program.end     end
  def rythme  ; @rythme ||= program.rythme  end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------


end # /Cal
end # /Program
end # /Unan
