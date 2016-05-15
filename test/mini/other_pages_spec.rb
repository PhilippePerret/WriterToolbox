# encoding: UTF-8

verbose

test_route "admin/dashboard" do
  description "Un user quelconque ne peut pas atteindre le tableau de bord administration"
  html.has_error "Section administration"
end

test_route "forum/home" do
  description "Un user quelconque peut atteindre le forum"
  html.has_title('Forum')
end
