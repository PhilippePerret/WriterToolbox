# encoding: UTF-8

=begin

  Feuille de test pour tester la création d'un user.

=end

test_base "users.users" do
  NOMBRE_INIT_USERS = count
  NOMBRE_INIT_USERS.eq(3, {sujet: "Le nombre d'users"})

  NOMBRE_INIT_USERS.not_bigger_than(5, {sujet: "Le nombre d'users"})
end
