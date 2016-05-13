# encoding: UTF-8
=begin
Test du login
=end

require './data/secret/data_phil'
dform = {
  id: "form_user_login",
  action: "user/login",
  fields:{
    login_mail:      DATA_PHIL[:mail],
    login_password:  DATA_PHIL[:password]
  }
}
test_form "user/signin", dform, "Login correct d'un user" do |f|

  f.exist
  f.fill(submit: true)
  f.has_message "Bievenue Phil !"

end


test_form "user/login", dform, "Mauvais login d'un user" do |f|
  new_data = {submit: true}
  f.fill(new_data.merge(:login_mail => ""))
  f.has_error "Il faut fournir votre mail."

  f.fill(new_data.merge(:login_password => "", login_mail: DATA_PHIL[:mail]))
  f.has_error "Il faut fournir votre mot de passe."

  f.fill(new_data.merge(login_mail: "bad@mail.fr", login_password: "mauvaismotdepasse"))
  f.has_error "Je ne vous reconnais pas. Merci d'essayer encore."
end

test_route "bad/route", "Test de mauvaise route" do |r|
  r.responds
end

test_route "bad/autreroute", "Autre test de mauvaise route" do |r|
  r.responds
end
