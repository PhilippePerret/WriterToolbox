# encoding: UTF-8
=begin

Préambule de l'application, après que tout a été chargé

=end
def execute_preambule
  User.init
  app.check_ticket
  user.do_after_load
end
