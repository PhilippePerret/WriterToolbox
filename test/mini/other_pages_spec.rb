# encoding: UTF-8

# verbose

test_route "admin/dashboard" do
  description "Un user quelconque ne peut pas atteindre le tableau de bord administration"
  html.inspect
  html.has_error "Section réservée à l'administration."
end

test_route "forum/home" do
  description "Un user quelconque peut atteindre le forum"
  responds
  html.has_title('Forum')
end
