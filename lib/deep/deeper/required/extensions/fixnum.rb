# encoding: UTF-8
class ::Fixnum
  DUREE_MINUTE  = 60
  DUREE_HEURE   = 60 * DUREE_MINUTE
  DUREE_JOUR    = 24 * DUREE_HEURE

  # ---------------------------------------------------------------------
  #   Classe
  # ---------------------------------------------------------------------
  class << self

  end

  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # Pour compatiblité avec autres objets
  def to_i_inn
    self
  end

  # Pour compatibilité avec autres objets
  def nil_if_empty
    self
  end

  def in_hidden attrs = nil
    self.to_s.in_hidden attrs
  end

  def as_tarif
    self.to_f.as_tarif
  end

  # Retourne la date correspondant au fixnum (quand c'est un timestamp)
  def as_date format = :dd_mm_yyyy
    format_str =
    case format
    when :dd_mm_yyyy  then "%d %m %Y"
    when :dd_mm_yy    then "%d %m %y"
    when :mm_yyyy     then "%m %Y"
    when :mm_yy       then "%m %y"
    when :d_mois_yyyy then return as_human_date
    when :d_mois_court_yyyy then return as_human_date false
    else
      nil
    end
    unless format_str.nil?
      Time.at(self).strftime(format_str)
    end
  end
  MOIS_LONG = ['','janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août',
    'septembre', 'octobre', 'novembre', 'décembre']
  MOIS_COURT = ['','jan', 'fév', 'mars', 'avr', 'mai', 'juin', 'juil', 'août',
    'sept', 'oct', 'nov', 'déc']
  def as_human_date mois_long = true, with_clock = false
    mois = mois_long ? MOIS_LONG[Time.at(self).month] : MOIS_COURT[Time.at(self).month]
    Time.at(self).strftime("%e #{mois} %Y#{with_clock ? ' - %H:%M' : ''}").strip
  end

  def as_duree
    mns = self / 60
    sec = (self % 60).to_s.rjust(2,'0')
    if mns > 60
      hrs = mns / 60
      mns = (mns % 60).to_s.rjust(2,'0')
      if hrs > 24
        jrs = "#{hrs / 24} jours "
        hrs = hrs % 24
      end
      hrs = "#{hrs}h"
    else
      hrs = ""
      jrs = ""
    end
    "#{jrs}#{hrs}#{mns}'#{sec}\""
  end

  # @usage : <nombre>.day ou <nombre>.days
  # Retourne le nombre de secondes correspondantes
  def days
    self * DUREE_JOUR
  end
  alias :day :days

  def years
    self * DUREE_JOUR * 365
  end
  alias :year :years

  ##
  # Retourne le timestamp sous forme de date pour l'enregistrement
  # dans le calendrier en date inversée
  # Par exemple, l'heure 8 09 2015 - 10:15 retournera 20150908
  # Noter que c'est un Fixnum qui est retourné, pas un String
  def as_cal_date
    Time.at(self).strftime('%Y%m%d').to_i
  end

end
