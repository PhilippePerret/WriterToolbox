# encoding: UTF-8
=begin
Méthodes pratiques pour la classe User
=end

# `user`, dans le programme, correspond à l'utilisateur qui
# visite actuellement le site. Il peut être identifié.
def user
  @user ||= User::current
end
