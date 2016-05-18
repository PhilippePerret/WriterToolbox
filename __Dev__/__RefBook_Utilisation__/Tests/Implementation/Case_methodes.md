# Case-méthodes

Les “case-méthodes” sont les méthodes utilisées à l'intérieur des “test_méthodes” :

~~~ruby

  test_route "ma/route" do # <- une test-méthode
  
    responds # <- Une case-méthode ou un case-test de la route
    
    html.has_tag('div#titre) # <- une case-méthode de l'objet
                             #    `html`
  end

~~~

* [Évaluation de la case-méthode](#evaluationdelacasemethode)
<a name='evaluationdelacasemethode'></a>

## Évaluation de la case-méthode

Voilà un exemple typique de définition de case-méthode (ici dans la class `Fixnum`). L'exemple est détaillé plus bas.

~~~ruby

  # Affirme que le nombre courant est égal au nombre
  # passé en argument
  def eq compared, options=nil, inverse=nil
    options ||= {}
    option_evaluate = options.delete(:evaluate)
    option_strict   = !!options.delete(:strict)

    ok = option_strict ? ( self === compared ) : ( self == compared )

    option_evaluate && ( return ok )

    SiteHtml::TestSuite::Case::new(
      SiteHtml::TestSuite::current_test_method,
      result:           ok,
      positif:          !inverse,
      sujet:            options.delete(:sujet),
      sujet_valeur:     self,
      objet:            options.delete(:objet),
      objet_valeur:     compared,
      on_success:       "_SUJET_ est égal _OBJET_.",
      on_success_not:   "_SUJET_ n'est pas égal _OBJET_ (OK).",
      on_failure:       "_SUJET_ devrait être égal _OBJET_, il est égal à #{self}…",
      on_failure_not:   "_SUJET_ ne devrait pas être égal _OBJET_."
    ).evaluate
  end

~~~

Explication détaillée du code ci-dessus :

~~~ruby


  def eq compared, options=nil, inverse=nil
  
    # La méthode sera utilisé par <nombre>.eq(<autre nombre>)
    # +compared+ est la valeur envoyée à la méthode
    # Voir ci-dessous les options possibles
    # +inverse+ permet d'inverser le résultat de la case-méthode,
    # dans le cas par exemple de `not_<method>`
  
    options ||= {}
    
    option_evaluate = options.delete(:evaluate)
    # On ajoute :evaluate aux options lorsqu'on ne veut pas une 
    # méthode qui produise un success ou une failure, mais une méthode
    # qui retourne true ou false.
    
    option_strict   = !!options.delete(:strict)
    # :strict peut avoir différents sens en fonction des contextes.
    # pour un string, il faut que la valeur soit égale, pas seulement
    # contenue.
    
    option_sujet    = options.delete(:sujet)
    # Pour les messages plus clairs, on peut donner une sorte d'intitulé
    # au sujet, c'est-à-dire à l'élément qui doit être comparé à la
    # valeur fournie en premier argument.
    
    option_objet    = options.delete(:objet)
    # Pour les messages plus clairs, comme ci-dessus, mais pour l'objet
    # cette fois-ci, c'est-à-dire pour désigner la valeur à laquelle
    # doit être comparée le sujet.

    
    ok = option_strict ? ( self === compared ) : ( self == compared )
    # Ici, on procède à l'estimation proprement dite.

    option_evaluate && ( return ok )
    # On retourne la valeur de l'estimation si c'est seulement elle qui
    # est demandée
      
    # Sinon, il faut produire un succès ou un échec
    SiteHtml::TestSuite::Case::new(
      # Instanciation d'un nouveau case-test
      
      SiteHtml::TestSuite::current_test_method,
        # Si la test-méthode n'est pas envoyée en premier argument,
        # il faut la récupérer de cette manière.
        # Cette méthode est très imporante car c'est dedans qu'on 
        # afficher le message produit.
        
      result:           ok,
        # Le résultat de l'évaluation.
        
      positif:          !inverse,
        # On précise s'il faut inverser le résultat pour l'estimer.
        
      sujet:            option_sujet,
      sujet_valeur:     self,
      objet:            option_objet,
      objet_valeur:     compared,
        # Les 4 valeurs ci-dessus servent aux messages avec de les
        # rendre plus explicites.
      
      on_success:       "_SUJET_ est égal _OBJET_.",
        # Le message produit si on est en mode verbose et que c'est 
        # un sujet.
        # Noter que ce sont les valeurs sujet, sujet_valeur, objet, 
        # objet_valeur qui permettent d'utiliser les balises _SUJET_
        # et _OBJET_
        
      on_success_not:   "_SUJET_ n'est pas égal _OBJET_ (OK).",
      on_failure:       "_SUJET_ devrait être égal _OBJET_, il est égal à #{self}…",
      on_failure_not:   "_SUJET_ ne devrait pas être égal _OBJET_."
        # Les trois autres messages servent à construire tous les types
        # de messages possibles en fonction de l'inverse ou de l'échec.

    ).evaluate
      # Il faut bien entenu évaluer cette instance pour produire le cas.
  end

~~~
