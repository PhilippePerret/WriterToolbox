# encoding: UTF-8
=begin

  Extention de la classe Object pour avoir les méthodes
  `__test_is?` et `__test_has?` qui permettent de tester
  l'appartenance et l'égalité de toutes les classes.

=end
class Object

  # Retourne true si self est égal à +value+ en respectant
  # exactement (strict = true) ou à peu près la valeur.
  # Suivant la classe de self, le test peut être différent.
  # Par exemple, pour un String, on teste à l'aide d'une
  # expression régulière.
  #
  # La méthode met dans la propriété @__test_error la liste
  # des erreurs (String) qui ont été rencontrées.

  def __test_is?(value, strict = false)
    if self.class != value.class
      raise "Un #{self.class} ne peut pas être comparé à un #{self.class}"
    end
    pos =
      if strict
        self === value
      else
        case self
        when String
          (self =~ /^#{value}$/i) != nil
        else
          self == value
        end
      end
    pos || begin
      # À faire en cas de divergence
      strictement = strict ? ' strictement' : ''
      @__test_error =
        case self
        when String

        when Fixnum, Float
        else
          "#{self.inspect} est#{strictement} différent de #{value.inspect}"
        end
    end
    # On retourne toujours le résultat
    return pos
  end

  # Méthode qui retourne true si self contient +value+ et
  # false dans le cas contraire, quel que soit self (String,
  # Fixnum, etc.)
  def __test_has?(value, strict = false)
    pos =
      case self
      when Fixnum, Float
        raise "Impossible de traiter l'appartenance pour un objet de classe #{self.class}."
      when String
        case value
        when String, Fixnum, Float
          value = value.to_s
          ( self =~ (strict ? /#{value}/ : /#{value}/i) ) != nil
        else
          raise "Un String ne peut pas contenir un #{value.class}."
        end
      else
        # Cas normal
        self.include?( value )
      end
    pos || begin
      @__test_error =
        case self
        when Hash, Array, String
          "ne contient pas #{value.inspect}"
        end
    end
    # On retourne toujours le résultat
    return pos
  end
end
