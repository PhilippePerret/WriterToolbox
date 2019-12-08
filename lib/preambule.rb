# encoding: UTF-8
=begin

Préambule de l'application, après que tout a été chargé

=end
def execute_preambule
  app.benchmark('-> execute_preambule')
  debug '-> execute_preambule'
  debug "Visiteur courant au début du préambule : #{user.pseudo} ##{user.id}"
  # # Charge le dossier user propre à l'application
  # C'est déjà fait dans le required.rb
  # User.init
  # Barrière pour les users black-listés
  User.die_current_user_if_black_ip
  app.check_ticket
  app.check_visit_as_user
  user.do_after_load
  debug "Visiteur courant à la fin du préambule : #{user.pseudo} ##{user.id}"
  # app.session['user_id'] = user.id
  debug "app.session['user_id'] = #{app.session['user_id']}"
  debug '<- execute_preambule'
  app.benchmark('<- execute_preambule')
end
