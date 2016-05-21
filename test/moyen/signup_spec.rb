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

  # Mettre le nombre actel de users dans la
  # variable test `:users_count`
  let(:users_count){count}
  show "Nombre users : #{users_count}"

  # On s'assure que la rangée n'existe pas déjà
  row(pseudo: user_pseudo, mail: user_mail).not_exists

end

test_form "user/signup", data_form do

  exists

end

test_form "user/create", data_form do

  fill_and_submit

  html.has_title("Vous êtes inscrite !", 1)

end

test_base "users.users" do
  description "L'user est bien enregistré dans la base de données"
  # Le nombre de users doit avoir été incrémenté d'1
  count.eq( users_count + 1, sujet: "Le nouveau nombre de users" )
  row(pseudo: user_pseudo, mail: user_mail).exists
end
