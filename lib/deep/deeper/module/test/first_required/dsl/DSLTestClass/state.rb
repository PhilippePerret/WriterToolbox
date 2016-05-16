# encoding: UTF-8
class DSLTestMethod

  # Retourne true si la test-method a été un succès, c'est-à-dire
  # qu'elle n'a généré aucun message d'erreur.
  def success?
    @is_a_success = (!fatal? || (@is_not_a_success != true)) if @is_a_success === nil
    @is_a_success
  end

  # Retourne TRUE si la test-méthode est de type `route`, i.e.
  # elle charge le module ModuleRouteMethode. Si c'est le cas
  # la test-méthode répond à route_test? qui surclasse cette méthode
  def route_test?
    false
  end

  def verbose?              ; @verbose end

  # Retourne true si le test de cette test-méthode doit être
  # silencieux. Cette valeur n'est mise à true que si `quiet` est
  # explicitement définie dans le code du fichier test. Sinon, la
  # valeur est nil.
  def quiet? ; @quiet end

  # Retourne true si on est en mode fatal, le mode par défaut
  # des tests, qui interrompt tout test-méthode lorsque qu'un
  # case-test échoue.
  def fatal?
    @is_not_fatal != true
  end
end
