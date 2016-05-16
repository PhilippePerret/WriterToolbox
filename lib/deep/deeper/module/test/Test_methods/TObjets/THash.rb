# encoding: UTF-8
=begin

Class THash
-----------
Extension des Hash pour les tests

  WARNING
    Pour l'instanciation d'un hash de test, il faut obligatoirement
    fournir la méthode de test (test-méthode) dans laquelle il est
    utilisé :
    th = THash::new( test_methode )
    th.merge!(...)

=end
class THash < Hash

  ERROR = {
    actual_value:         "sa valeur est %s",
    unknown_property:     "cette propriété est inconnue"
  }

  # Test-méthode (pour savoir où enregistrer le résultat des
  # méthodes d'évaluation)
  attr_reader :tmethod

  # +tmethod+ Instance de la méthode de test à l'intérieur de
  # laquelle.
  def initialize tmethod, default_value=nil
    @tmethod = tmethod
    super(default_value)
  end

  # Produit un succès si le {THash} contient les données spécifiées
  # dans +hdata+ ou une failure dans le cas contraire
  def has hdata, options=nil, inverse=false
    options ||= Hash::new

    option_evaluate = options.delete(:evaluate)

    # On teste les contenus
    hdiff = Hash::new
    hdata.each do |k, v|
      hdiff.merge!(k => {expected:v, existe:(self.has_key?(k)), valeur: self[k]}) if self[k] != v
    end

    # Débug
    if debug?
      debug "--- comparaison de deux hash ---"
      debug "Compare : #{hdata.inspect}"
      debug "Avec : #{self.inspect}"
    end

    # Évaluation
    ok = hdiff.empty?
    return ok if option_evaluate

    # Pour l'affichage
    hinspected = hdata.inspect
    if ok != !inverse
      hdiff = "différences : " + hdiff.collect do |k, dv|
        kerreur = dv[:existe] ? :actual_value : :unknown_property
        erreur = ERROR[kerreur] % [dv[:valeur].inspect]
        "la propriété #{k.inspect} devrait avoir la valeur #{dv[:expected].inspect} et #{erreur}"
      end.pretty_join
    end

    # Production du cas
    SiteHtml::TestSuite::Case::new(
      tmethod,
      result:         ok,
      positif:        !inverse,
      on_success:     "Le Hash contient bien #{hinspected}.",
      on_success_not: "Le Hash ne contient pas #{hinspected} (OK).",
      on_failure:     "Le Hash devrait contenir #{hinspected} (#{hdiff}).",
      on_failure_not: "Le Hash ne devrait pas contenir #{hinspected}."
    ).evaluate
  end

  def has_not hdata, options=nil
    has(hdata, options, true)
  end
  def has? hdata, options=nil
    has(hdata, (options||{}).merge(evaluate:true))
  end
  def has_not? hdata, options=nil
    has(hdata, (options||{}).merge(evaluate:true), true)
  end


  def debug?
    @is_debugging ||= SiteHtml::TestSuite::debug?
  end
end
