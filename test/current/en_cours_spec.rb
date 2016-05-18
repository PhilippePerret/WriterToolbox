# encoding: UTF-8

=begin

  Feuille de test pour tester la création d'un user.

=end

test_base "users.users" do
  NOMBRE_INIT_USERS = count
  count.eq(5, {sujet: "Le nombre de users"})
end
