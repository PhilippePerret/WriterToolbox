# encoding: UTF-8
=begin

  Extention de la classe Object pour avoir les méthodes
  `__test_is?` et `__test_has?` qui permettent de tester
  l'appartenance et l'égalité de toutes les classes.

=end
class Object

  # ---------------------------------------------------------------------
  #   MÉTHODES FONCTIONNELLES
  # ---------------------------------------------------------------------
  if self.respond_to? :method_mmissing
    debug "Oui, il répond à method_missing"
    alias :original_method_missing :method_missing
  end

  def method_missing method_name, *args, &block
    mname = method_name.to_s
    if mname[0..2] == 'is_'
      for_not = mname.start_with?('is_not_')
      flat_meth   = method_name.to_s.sub(for_not ? /^is_not_/ : /^is_/,'')
      quest_meth  = "#{flat_meth}?".to_sym
      if self.respond_to?(quest_meth)
        # L'objet répond à une méthode correspondant à la
        # méthode appelée is_ ou is_not_. Il suffit donc de
        # l'appeler et de dire que le résultat doit être
        # soit true soif false puisque c'est la valeur qu'est
        # censée retourner une méthode '?'
        rs = self.send(quest_meth)
        resultat = rs == !for_not
        # On ajoute un message aux options dans le cas où
        # il n'aurait pas été défini, pour ne pas avoir le
        # message "true est égal à true"
        options = defaultize_options(args[0], !for_not)
        options[:message] ||= begin
          if resultat
            if for_not
              "#{options[:sujet]} #{quest_meth.inspect} retourne faux (OK)."
            else
              "#{options[:sujet]} #{quest_meth.inspect} retourne vrai."
            end
          else
            if for_not
              "#{options[:sujet]} #{quest_meth.inspect} devrait être faux."
            else
              "#{options[:sujet]} #{quest_meth.inspect} devrait être vrai."
            end
          end
        end
        # On produit ensuite le test en fonction du
        # résultat
        rs.is(true, options)
      end
    else
      if self.respond_to?(:self_method_missing)
        self.send(:self_method_missing, method_name)
      end
    end
  end

  # ---------------------------------------------------------------------
  #   MÉTHODES DE TEST
  # ---------------------------------------------------------------------
  # Traitement des options envoyées à toutes les méthodes de
  # test de type `is`, `has` & dérivées
  def defaultize_options options, expected
    options ||= {}
    options.key?(:strict) || options.merge!(strict: false)
    options[:sujet] = defaultize_sujet_or_value(options[:sujet], self)
    options[:objet] = defaultize_sujet_or_value(options[:objet], expected)
    return options
  end
  def defaultize_sujet_or_value foo, foo_value
    foo_value =
      case foo_value
      when String, Fixnum, Float, Hash, Array, TrueClass, FalseClass, NilClass
        foo_value.inspect
      else
        class_name = foo_value.instance_of?(Class) ? foo_value.name : foo_value.class.name
        "objet de class #{class_name}"
      end

    if foo
      foo % {value: foo_value}
    else
      foo_value
    end
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
    options[:message] ||=
      case rs
      when TrueClass
        "#{options[:sujet]} est#{strictement} égal à #{options[:objet]}."
      when FalseClass
        "#{options[:sujet]} devrait être#{strictement} égal à #{options[:objet]} (il vaut #{self.inspect})."
      end

      # On évalue ce cas pour produire le success ou la failure
    args = {
      result:   rs,
      message:  options[:message]
    }
    SiteHtml::TestSuite::Case.new(current_tmethod, args).evaluate

    rs # pour les tests
  end

  def is_not(value, options = nil)
    options = defaultize_options(options, value)
    strict  = options.delete(:strict)
    rs = !__test_is?( value, strict )

    strictement = strict ? ' strictement' : ''
    options[:message] ||=
      case rs
      when TrueClass
        "#{options[:sujet]} est#{strictement} différent de #{options[:objet]}."
      when FalseClass
        "#{options[:sujet]} devrait être#{strictement} différent de #{options[:objet]}."
      end

    # On évalue ce cas pour produire le success ou la failure
    args = {
      result:   rs,
      message:  options[:message]
    }
    SiteHtml::TestSuite::Case.new(current_tmethod, args).evaluate

    rs # pour les tests

  end

  def is_instance_of(expected, options = nil)
    options = defaultize_options options, expected
    rs = self.instance_of?(expected)
    options[:message] ||= begin
      if rs
        "#{options[:sujet]} est une instance d'#{options[:objet]}."
      else
        "#{options[:sujet]} devrait être une instance d'#{options[:objet]}."
      end
    end
    args = {
      result: rs,
      message: options[:message]
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
