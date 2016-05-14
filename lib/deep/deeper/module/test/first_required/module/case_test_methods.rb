# encoding: UTF-8
=begin

  Méthodes fonctionnelles dont peuvent hériter tous les
  modules contenant des "case-méthodes"
  (cf. la définition)

=end
module ModuleCaseTestMethods

  # Pour traiter les méthodes plurielles. Envoyer simplement les
  # deux arguments attendus à cette méthode, plus la méthode de
  # traitement
  # Par exemple, pour la méthode `has_tags` :
  #   evaluate_as_pluriel :has_tag, ['div#mon', 'div#ton']
  #
  # Si +options+ est défini, c'est un hash de options générales
  # qui doivent être transmises à chaque élément.
  # Noter que dans ce cas, les éléments de +arr+ ne doivent pas
  # définir d'options en dernier argument, sinon ces options
  # générales seraient ajoutées comme argument supplémentaires
  # et entraineraient un bug.
  #
  # La méthode retourne le résultat de l'évaluation
  # dans le cas où ce sont des méthodes-?.
  #
  def evaluate_as_pluriel method, arr, options=nil

    is_interrogative = method.to_s.end_with?("?")
    total_value = true if is_interrogative

    # Les éléments de la liste peuvent être :
    #   - soit un string seul (le premier argument de la méthode +method+)
    #   - soit un array définissant les arguments à envoyer à la
    #     méthode +method+
    # Mais peu importe car le `*` transforme en liste whatever il
    # reçoit, un élément seul ou une liste.
    #
    res = arr.collect do |args|
      unless options.nil?
        args = [args] unless args.instance_of?(Array)
        args << options
      end
      send(method, *args) # c'est le résultat qu'on doit collecter
    end.compact.uniq

    return res == [true]
  end

end

# On inclut ce module à DSLTestClass
if defined?(DSLTestClass)
  class DSLTestClass; include ModuleCaseTestMethods end
end
