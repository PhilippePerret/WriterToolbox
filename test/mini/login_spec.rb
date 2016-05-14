# encoding: UTF-8
=begin
Test du login
=end

# require './data/secret/data_phil'
# dform = {
#   id: "form_user_login",
#   action: "user/login",
#   fields:{
#     login_mail:      {name:"login[mail]",     value: DATA_PHIL[:mail]},
#     login_password:  {name:"login[password]", value: DATA_PHIL[:password]}
#   }
# }

# test_form "user/signin" do
#   html
# end

# test_form "user/signin", dform, "Le form login existe à l'adresse user/signin" do |f|
#
#   f.exist
#
#   html
#
# end
#
# test_form "user/login", dform, "Un user peut se connecter avec un bon login" do |f|
#
#   f.fill_and_submit
#   f.has_message "Bienvenue, Phil"
#
# end
