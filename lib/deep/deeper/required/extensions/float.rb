class ::Float

  class << self
    def devise
      @devise ||= "€"
    end
    def devise= value
      @devise = value
    end
    def separateur_decimal
      @separateur_decimal ||= ","
    end
    def separateur_decimal= value
      @separateur_decimal = value
    end
  end # << self

  # {String} Retourne le flottant comme un tarif, avec le bon
  # séparateur et la bonne devise.
  def as_tarif
    t = "#{self}"
    euros, centimes = t.split('.')
    centimes += "0" if centimes.length < 2
    "#{euros}#{self.class::separateur_decimal}#{centimes}#{self.class::devise}"
  end

end
