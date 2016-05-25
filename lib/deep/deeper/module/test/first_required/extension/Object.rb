# encoding: UTF-8
=begin

  Extention de la classe Object pour avoir les méthodes
  `__test_is?` et `__test_has?` qui permettent de tester
  l'appartenance et l'égalité de toutes les classes.

=end
class Object

  def defaultize_options options, expected
    options ||= {}
    options.key?(:strict) || options.merge!(strict: false)
    options[:sujet] ||= self.inspect
    options[:objet] ||= expected.inspect
    return options
  end

  def current_tmethod
    nil # pour le moment
  end

  # Produit un case-test d'égalité
  def is(value, options = nil)
    options = defaultize_options(options, value)

    strict = options.delete(:strict)
    rs = __test_is?( value, strict )

    strictement = strict ? ' strictement' : ''
    message =
      case rs
      when TrueClass
        "#{options[:sujet]} est#{strictement} égal à #{options[:objet]}."
      when FalseClass
        "#{options[:sujet]} devrait être#{strictement} égal à #{options[:objet]}."
      end

      # On évalue ce cas pour produire le success ou la failure
    args = {
      result:   rs,
      message:  message
    }
    SiteHtml::TestSuite::Case.new(current_tmethod, args).evaluate

    rs # pour les tests
  end

  def is_not(value, options = nil)
    options = defaultize_options(options, value)
    strict  = options.delete(:strict)
    rs = !__test_is?( value, strict )

    strictement = strict ? ' strictement' : ''
    message =
      case rs
      when TrueClass
        "#{options[:sujet]} est#{strictement} différent de #{options[:objet]}."
      when FalseClass
        "#{options[:sujet]} devrait être#{strictement} différent de #{options[:objet]}."
      end

    # On évalue ce cas pour produire le success ou la failure
    args = {
      result:   rs,
      message:  message
    }
    SiteHtml::TestSuite::Case.new(current_tmethod, args).evaluate

    rs # pour les tests

  end

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
      false
    else
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
    end
  end

  # Méthode qui retourne true si self contient +value+ et
  # false dans le cas contraire, quel que soit self (String,
  # Fixnum, etc.)
  def __test_has?(value, strict = false)
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
  end
end
