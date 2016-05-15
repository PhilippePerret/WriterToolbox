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
  description "Un user peut se connecter avec un bon login"
  start_debug
  fill_and_submit
  html.has_message "Bienvenue, Phil"
  stop_debug
end
