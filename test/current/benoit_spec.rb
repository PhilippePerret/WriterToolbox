# encoding: UTF-8


login_user "Benoit"

test_route "admin/dashboard" do
  description "Un simple inscrit (Benoit) ne peut pas rejoindre la section d'administration."
  responds
  html.has_error "Section réservée à l'administration."
end
