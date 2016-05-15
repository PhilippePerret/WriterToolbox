# encoding: UTF-8
=begin
Test du login
=end

require './data/secret/data_phil'
dform = {
  id: "form_user_login",
  action: "user/login",
  fields:{
    login_mail:      {name:"login[mail]",     value: DATA_PHIL[:mail]},
    login_password:  {name:"login[password]", value: DATA_PHIL[:password]}
  }
}


test_form "user/signin", dform  do
  description "Un login-form conforme existe à l'adresse user/signin"
  exist
end

test_form "user/login", dform do
  description "Un user peut se connecter avec ses bons identifiants"
  fill_and_submit
  html.has_message "Bienvenue, Phil"
end

dform_bad_login = {
  id: "form_user_login",
  fields: {
    login_mail:     {name:"login[mail]", value: DATA_PHIL[:mail]},
    login_password: {name:"login[password]", value: "badvalue"}
  }
}
test_form "user/login", dform_bad_login do
  description "Avec un mauvais login, impossible de s'identifier"
  fill_and_submit
  html.has_not_message "Bienvenue, Phil"
  html.has_error "Je ne vous reconnais pas"
end
