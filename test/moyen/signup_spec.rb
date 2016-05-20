# encoding: UTF-8
=begin

  Test d'intégration de l'inscription d'un user

=end

user_pseudo = "SonPseudo"
user_mail   = "pour@voir.net"
user_pwd    = "motdepasse"

data_form = {
  id: 'form_user_signup',
  action: 'user/create',
  fields:{
    user_pseudo: {name: 'user[pseudo]', value: user_pseudo},
    user_patronyme: {name: 'user[patronyme]',  value: "Patro#{NOW}"},
    user_sexe:      {name: 'user[sexe]',       value: 'F'},
    user_mail:      {name: 'user[mail]', value:user_mail},
    user_mail_conf: {name: 'user[mail_confirmation]', value: user_mail},
    user_password:  {name: 'user[password]', value: user_pwd},
    user_pwd_conf:  {name: 'user[password_confirmation]', value: user_pwd},
    user_captcha:   {name: 'user[captcha]', value: '366'}
  }
}

test_base "users.users" do
  description "L'user #{user_pseudo} n'existe pas dans la base de données des Users."
  row(pseudo: user_pseudo, mail: user_mail).not_exists
end

test_form "user/signup", data_form do

  exist

end

test_form "user/create", data_form do

  fill_and_submit

  html.has_message("Vous êtes inscrite !")

end

test_base "users.users" do
  description "L'user est bien enregistré dans la base de données"
  row(pseudo: user_pseudo, mail: user_mail).exists
end
