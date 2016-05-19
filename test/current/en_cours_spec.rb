# encoding: UTF-8

=begin

  Feuille de test pour tester la création d'un user.

=end

# test_base "users.users" do
#   # NOMBRE_INIT_USERS = count
#   # NOMBRE_INIT_USERS.eq(3, {sujet: "Le nombre d'users"})
#   #
#   # NOMBRE_INIT_USERS.not_bigger_than(5, {sujet: "Le nombre d'users"})
#
# end
# require './data/secret/data_phil'
# dform = {
#   fields: {
#     login_mail:     {name:'login[mail]', value: DATA_PHIL[:mail]},
#     login_password: {name:'login[password]', value: DATA_PHIL[:password]}
#   }
# }
# test_form "user/login", dform do
#   fill_and_submit
#
#   curl_request.header.has(status_code: 200)
#   # show "header: #{curl_request.header.pretty_inspect}"
#   # show "session_id: #{curl_request.session_id}"
#   # show "Session-id du test : #{app.session.session_id}"
#
# end


login_phil

test_route "admin/dashboard" do
  description "En tant qu'administrateur, je peux rejoindre le table de bord"
  # TODO ERROR LE Problème, c'est qu'ici, je ne charge par les cookies puisque
  # j'utilise Nokogori pour avoir la page.
  responds
  html.has_not_error
  html.has_link( 'admin/sync', text: 'SYNCHRONISATION' )
end
