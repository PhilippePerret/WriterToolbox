# encoding: UTF-8

NOW_T = Time.now
NOW   = Time.now.to_i

class Time
  MOIS = {
    0 => "janvier",
    1 => "février",
    2 => "mars",
    3 => "avril",
    4 => "mai",
    5 => "juin",
    6 => "juillet",
    7 => "août",
    8 => "septembre",
    9 => "octobre",
    10 => "novembre",
    11 => "décembre"
  }
  MOIS_COURT = {
    0 => "jan",
    1 => "fév",
    2 => "mars",
    3 => "avr",
    4 => "mai",
    5 => "juin",
    6 => "juil",
    7 => "août",
    8 => "sept",
    9 => "oct",
    10 => "nov",
    11 => "déc"
  }

  JOURS         = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]
  JOURS_COURTS  = ["lun", "mar", "mer", "jeu", "ven", "sam", "dim"]

  # Retourne le temps en nombre de millisecondes
  def to_ms
    (self.to_f * 1000.0).to_i
  end

  def today?
    toi = self.to_i.freeze
    toi >= today.start && toi <= today.end
  end
  def before_today?
    self.to_i < today.start
  end
  def after_today?
    self.to_i > today.end
  end
end
