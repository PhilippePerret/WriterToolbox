# encoding: UTF-8
=begin

  Module gérant les messages (succès et failure) ainsi que
  tous les messages d'erreur et les notifications.

=end
class DSLTestClass


  def success_messages
    @success_messages ||= Array::new
  end

  # En fait, il ne peut y avoir qu'un seul message ici, le message
  # d'erreur éventuel qui a interrompu le cas. Mais je laisse quand
  # même comme ça au cas où on puisse définir un mode "sans-erreur"
  # qui permettent une certaine forme de test qui n'est pas interrompu
  # lors d'une erreur
  def failure_messages
    @failure_messages ||= Array::new
  end

  # ---------------------------------------------------------------------
  #   Helper methods
  #   --------------
  #   Pour la mise en forme des messages
  # ---------------------------------------------------------------------

  def messages_output
    c = String::new
    c += success_messages.collect do |mess|
      mess.in_div(class:'suc')
    end.join('')
    c += failure_messages.collect do |mess|
      mess.in_div(class:'err')
    end.join('')
    c.in_div(class:"atest #{success? ? 'suc' : 'err'}")
  end

  # ---------------------------------------------------------------------
  #   Message de programme (erreurs et notices)
  # ---------------------------------------------------------------------

  def error_no_test_route method
    @template_html ||= begin
      raise "Impossible d'utiliser la méthode `%{method}` avec une test-méthode qui n'est pas de type route. Pour que la test-méthode puisse utiliser ce test-case, ajouter `include ModuleRouteMethods` à son code."
    end
    @template_html % {method: method}
  end

end
