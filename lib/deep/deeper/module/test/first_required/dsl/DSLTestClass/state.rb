# encoding: UTF-8
class DSLTestClass

  # Retourne true si la test-method a été un succès, c'est-à-dire
  # qu'elle n'a généré aucun message d'erreur.
  def success?
    @is_success ||= failure_messages.count == 0
  end

  # Retourne TRUE si la test-méthode est de type `route`, i.e.
  # elle charge le module ModuleRouteMethode. Si c'est le cas
  # la test-méthode répond à route_test? qui surclasse cette méthode
  def route_test?
    false
  end
end
