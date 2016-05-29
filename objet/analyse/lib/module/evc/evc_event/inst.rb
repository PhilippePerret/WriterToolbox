# encoding: UTF-8
=begin

Class Evc::Event
----------------
Classe des évènements de l'évènemencier
=end
class Evc
class Event

  # {Evc} L'évènemencier possédant l'évènement
  attr_reader :evc

  # {String} La ligne brute, telle qu'enregistrée dans le fichier
  # de l'évènemencier
  # Cette ligne est obligatoirement fournie à l'instanciation
  attr_reader :raw_line

  attr_reader :horloge

  # {String} Le résumé
  # Peut contenir certaines valeurs spéciales :
  #   _END      Fin du film
  attr_reader :resume

  # {String|Nil} Une note sur l'évènement, ou nil
  attr_reader :note

  # {Fixnum|Nil} La durée de l'évènement, if any
  # Si evc.specs.temps_page?, alors ce sont des pages, pas des
  # secondes
  attr_reader :duree

  # {Fixnum|Nil} L'indice de l'évènement réel, dans la liste
  # complète des évènements
  attr_reader :indice_real_evt


  # On initie un évènement à l'aide de sa ligne qu'on va
  # exploser tout de suite
  # +evc+ L'évènemencier
  def initialize evc, raw_line
    @evc = evc
    @raw_line = raw_line
    parse_line
  end

  # ---------------------------------------------------------------------
  #   Data volatiles
  # ---------------------------------------------------------------------

  # Le time en seconde d'après l'horloge
  def time
    @time ||= begin
      unless horloge.nil? || in_page?
        dh = horloge.split(":").reverse
        dh[0].to_i + dh[1].to_i * 60 + dh[2].to_i * 3600
      else
        nil
      end
    end
  end

  # Retourne true quand la valeur de position ou de
  # durée de l'évènemencier est exprimée en pages.
  def in_page?
    @in_page = evc.specs.temps_page? if @in_page === nil
    @in_page
  end

  # ---------------------------------------------------------------------
  #   Méthodes diverses
  # ---------------------------------------------------------------------

  # = main =
  #
  # Méthode qui parse la ligne de donnée et dispatche les données
  def parse_line

    # On explode en découpant selon les " | " (noter les espaces),
    # on stripe chaque élément en mettant à NIL ceux qui sont vides
    @dline = raw_line.split(" | ").collect { |e| e.strip.nil_if_empty }

    # On dispatche
    @horloge, @duree, @resume, @note, @indice_real_evt = @dline

    # L'horloge peut avoir également été fournie en temps, il faut
    # donc checker. Noter que si c'est un nombre de secondes, ça ne
    # gêne pas.
    unless @horloge.match(/\:/)
      @time     = @horloge.to_i
      @horloge  = @time.s2h
    end

    # Correction de certaines valeurs pour qu'elles aient
    # leur bonne classe
    @indice_real_evt  = @indice_real_evt.to_i   unless @indice_real_evt.nil?
    @duree            = @duree.to_i             unless @duree.nil?
  end


  # (re-)Construit la ligne brute de donnée de l'évènement, pour
  # enregistrement dans le fichier de l-évènemencier
  def as_raw_line
    d = Array::new
    d << horloge  .to_s
    d << duree    .to_s
    d << resume   .to_s
    d << note     .to_s
    d << indice_real_evt.to_s
    d = d.join(" | ")
    begin
      d = d[0..-4]
    end while d.end_with?(" | ")
    d
  end

end #/Event
end #/Evc
