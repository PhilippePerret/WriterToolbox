# encoding: UTF-8
=begin
Class Evc::Specs
----------------
Spécificité de l'évènemencier. Correspond aux infos de la première ligne
=end
require 'json'
class Evc
class Specs

  # {Evc} Évènemencier maitre
  attr_reader :evc

  # {String} La ligne brute telle qu'écrite dans le fichier
  # en première ligne. C'est du code JSON
  attr_reader :raw_line

  # {Hash} Les données d'entête. C'est la ligne brute après
  # parse par json
  attr_reader :data

  # +evc+ Instance {Evc} de l'évènemencier
  def initialize evc, raw_line
    @evc      = evc
    @raw_line = raw_line
    debug "raw_line = #{raw_line.inspect}"
    @data = ( JSON.parse raw_line )
  end

  # ---------------------------------------------------------------------
  # Data d'entête
  # ---------------------------------------------------------------------
  # {String} Titre humain de l'évènemencier
  def evc_titre
    @evc_titre    ||= data["evc_titre"]
  end
  # {String} ID du film de l'évènemencier
  def film_id
    @film_id  ||= data["film_id"]
  end

  # {String} Le titre humain du film
  def film_titre
    @film_titre ||= data["film_titre"]
  end

  # {Fixnum} Date-timestamp de la création de lévènemencier
  def date
    @date ||= data["date"]
  end

  # {String} Format des temps (même de l'horloge de départ)
  # Soit 'page', soit 'seconde' (défaut)
  # Permet de définir temps_page? et temps_seconde?
  def format_duree
    @format_duree ||= (data["format_duree"] || 'seconde')
  end

  # {String} Échelle (cf. Evc::Specs::SCALES)
  def scale
    @scale ||= data["scale"]
  end

  # {String} Type de l'évènemencier
  # cf. Evc::Specs::TYPES
  def type
    @type || data["type"]
  end

  # {Fixnum} Durée en secondes
  # C'est la durée de couverture de l'évènemencier
  def duree
    @duree ||= data["duree"]
  end

  # {String} Peut-être une note enregistrée dans l'entête
  def note
    @note ||= data["note"]
  end

  # {Fixnum|Nil} Quand le premier temps est 0:00:00 mais que
  # l'évènement se trouve plus loin dans le film.
  # Note : peut être en seconde ou en horloge
  def real_start
    @real_start ||= data["real_start"]
  end

  # {Bool} True si l'évènemencier est fragmentaire, c'est-à-dire
  # qu'il ne couvre pas l'intégralité du film.
  # Attention : Un brin ne commence pas forcément au début et ne
  # finit pas forcément à la fin MAIS n'est PAS fragmentaire pour
  # autant.
  def fragment
    @fragment ||= data["fragment"]
  end


  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------

  # {Fixnum} Nombre d'évènements dans le fichier, juste
  # pour contrôle.
  # Attention, la donnée est dans "events" mais il faut
  # utiliser `nombre_events` ici car `events` est réservé
  # pour les évènements.
  def nombre_events
    @nombre_events ||= data["events"]
  end

  def date_humaine
    @date_humaine ||= begin
      (date || Time.now.to_i - 360000).as_human_date
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'états
  # ---------------------------------------------------------------------
  def fragment?
    fragment == true
  end

  def temps_seconde?
    @is_temps_seconde ||= (format_duree == 'seconde')
  end
  def temps_page?
    @is_temps_page ||= (format_duree == 'page')
  end

  # ---------------------------------------------------------------------
  # Méthodes diverses
  # ---------------------------------------------------------------------

  # Hash qui permettra d'enregistrer la ligne d'entête.
  # C'est en fait la donnée `data`, mais reconstituée
  def as_hash
    @as_hash ||= begin
      h = {
        film_id:      film_id,
        film_titre:   film_titre,
        evc_titre:    evc_titre,
        duree:        duree,
        type:         type || "brin", # !!! À MODIFIER !!!
        scale:        scale,
        format_duree: format_duree,
        events:       evc.events.count,
        date:         (date || Time.now.to_i)
      }
      h.merge!(fragment: fragment? ) unless @is_fragment === nil
      h.merge!(real_start: real_start ) unless real_start.nil?
      h
    end
  end

end #/Specs
end #/Evc
