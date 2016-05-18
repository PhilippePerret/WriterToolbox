class Fixnum

  # Affirme que le nombre courant est égal au nombre
  # passé en argument
  def eq compared, options=nil, inverse=nil
    options ||= {}
    option_evaluate = options.delete(:evaluate)
    option_strict   = options.delete(:strict)
    option_sujet    = options.delete(:sujet) || self
    option_objet    = options.delete(:objet) || compared

    ok = option_strict ? ( self === compared ) : ( self == compared )

    unless option_evaluate === false
      SiteHtml::TestSuite::Case::new(
        SiteHtml::TestSuite::current_test_method,
        result:           ok,
        positif:          !inverse,
        on_success:       "#{option_sujet} est égal à #{option_objet}.",
        on_success_not:   "#{option_sujet} est différent de #{option_objet} (OK).",
        on_failure:       "#{option_sujet} devrait être égal à #{option_objet}…",
        on_failure_not:   "#{option_sujet} ne devrait pas être égal à #{option_objet}."
      ).evaluate
    else
      return ok
    end
  end
  def not_eq( compared, options=nil )
    eq compared, options, true
  end
  def eq?( compared, options=nil )
    eq compared, (options || {}).merge(evaluate: true)
  end
  def not_eq?( compared, options=nil )
    eq compared, (options || {}).merge(evaluate: true), true
  end

  def bigger_than

  end
  def smaller_than

  end
end
