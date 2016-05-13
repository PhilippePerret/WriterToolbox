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
test_form "user/signin", dform, "Le form login existe à l'adresse user/signin" do |f|

  f.exist

end

test_form "user/login", dform, "Bon login d'un user" do |f|

  f.fill_and_submit
  debug "\n\n\n--- DÉBUT TEST f.has_message ---"
  f.has_message "Bienvenue Phil"
  debug "\n--- FIN TEST f.has_message ---\n\n\n"

end


test_form "user/login", dform, "Mauvais login d'un user" do |f|
  # form[:fields][:login_mail][:value] = ""
  f.fill_and_submit( login_mail: "" )
  f.has_error "Il faut fournir votre mail."

  f.fill_and_submit(login_password: "")
  f.has_error "Il faut fournir votre mot de passe."

  f.fill_and_submit(login_mail: "bad@mail.fr", login_password: "mauvaismotdepasse")
  f.has_error "Je ne vous reconnais pas. Merci d'essayer encore."
end
