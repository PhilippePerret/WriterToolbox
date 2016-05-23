# encoding: UTF-8
=begin

  Test d'intégration de l'inscription d'un user

=end

# Ce test ne doit surtout pas être joué sur le site distant, car
# il modifierait la liste des utilisateurs dans la base
only_offline

# Description de la feuille de test
description <<-HTML
Test de l'inscription d'un utilisateur avec des paramètres valides
pour voir :

* s'il sera bien enregistré dans la base des users,
* si sa donnée indiquera qu'il a un statut de simple user,
* si sa donnée indiquera qu'il a un statut de simple lecteur du forum,
* si sa donnée indiquera bien que son mail n'est pas confirmé,
* s'il recevra bien le mail de bienvenue,
* s'il recevra bien le mail lui demandant de confirmer son mail
HTML

user_pseudo = "SonPseudo"
user_mail   = "pour@voir.net"
user_pwd    = "motdepasse"

let(:start_time){ Time.now.to_i }

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

  # L'user a été enregistré dans la base de données
  r = row(pseudo: user_pseudo, mail: user_mail)
  r.exists

  # On prend l'identifiant de l'user
  let(:user_id){r.data[:id]}

  options = r.data[:options]

  bit1 = TString.new(self, options[0])
  # Ses données indiquent bien qu'il n'a qu'un statut
  # de simple user
  # options[0].is('0', {sujet: "Premier bit d'options (statut user)"})
  bit1.is('0', {sujet: "Premier bit d'options (statut user)"})

  # # Ses données indique bien qu'il n'a qu'un statut de
  # # simple lecteur sur le forum
  # options[1].is('0', {sujet: "Deuxième bit d'options (statut forum)"})
  #
  # # Ses données indiquent bien que son mail n'a pas
  # # encore été validé
  # options[2].is('0', {sujet: "Non confirmation de mail"})


end

test_base "site_hot.tickets" do
  description "Un ticket a été enregistré pour confirmer le mail"
  code = "User::get(#{user_id}).confirm_mail"
  r = row(user_id: user_id, code: code)
  r.exists
  # On récupère l'ID du ticket pour voir s'il est correct dans
  # le mail.
  let(:ticket_id) { r.data[:id] }
end

test_user get(:user_id) do
  description "L'user créé (##{user_id}) a reçu deux mails valides"
  # Premier mail lui annonçant son inscription
  non_fatal

  has_mail(
    subject: "Bienvenue !",
    message: ['SonPseudo, bienvenue sur la Boite à Outils de l\'Auteur'],
    sent_after: start_time - 1
  )
  # Deuxième mail lui demandant de confirmer son mail
  lien_confirmation = "<a href=\"http://www.laboiteaoutilsdelauteur.fr?tckid=#{ticket_id}\">Confirmation de votre mail</a>"
  has_mail(
    subject: 'Merci de confirmer votre mail',
    message: [
      'Merci de bien vouloir confirmer votre adresse-mail',
      lien_confirmation
    ],
    sent_after: start_time - 1
    )
end
