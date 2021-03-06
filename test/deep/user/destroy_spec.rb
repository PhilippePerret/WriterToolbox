# encoding: UTF-8

only_offline

description <<-MD
Test complet de la destruction d'un user.

Ce test vise à vérifier que toutes les opérations sont faites sur un
user qui a beaucoup participé au site, aussi bien dans le forum que
dans les analyses.

Dans un premier temps, il faut créer l'user :

* création de l'user,
* on lui donne les autorisations nécessaires pour participer au forum,
* on lui fabrique des messages forum
* on l'inscrit au programme UN AN UN SCRIPT

Le principal du programme de destruction de l'user se fait dans
le module `./objet/user/destroy.rb`

MD

let(:start_time){ Time.now.to_i - 1 }

let(:user_mail){ 'unfakemail@yahoo.fr' }
let(:user_pwd){ 'unmotdepassevalide' }

# Table de user, dans laquelle on va mettre toutes les
# données récupérées
duser = {
  id:           nil,
  pseudo:       "UnPseudoPourUneUseuse",
  mail:         get(:user_mail),
  password:     get(:user_pwd),
  program_id:   nil,
  projet_id:    nil
}

# ---------------------------------------------------------------------
#   CRÉATION DE L'USER
# ---------------------------------------------------------------------
# Les données du formulaire pour créer entièrement l'user
dform = {
  fields: {
    user_pseudo:    {name: 'user[pseudo]', value: duser[:pseudo]},
    user_patronyme: {name: 'user[patronyme]', value: 'UnFake Patronyme'},
    user_mail:      {name: 'user[mail]',  value: duser[:mail]},
    user_mailconf:  {name:'user[mail_confirmation]', value: duser[:mail]},
    user_password:  {name:'user[password]', value: duser[:password]},
    user_pwdconf:   {name:'user[password_confirmation]', value: duser[:password]},
    user_sexe:      {name:'user[sexe]', value:'F'},
    user_captcha:   {name: 'user[captcha]', value: '366'}
  }
}


test_form "user/create", dform do
  fill_and_submit
  html.has_title("Vous êtes inscrite !", 1)
end



# On récupère l'ID du nouvel user
test_base "users.users" do
  r = row(pseudo: duser[:pseudo], mail: duser[:mail])
  r.exists
  # ID du nouvel user
  duser[:id] = r.data[:id]
  show "#{duser[:pseudo]} a pour identifiant ##{duser[:id]}"

  # -----------------------------------------
  # RÉGLAGE DES OPTIONS pour que l'user ait :
  # -----------------------------------------
  #   0 : Un simple user
  #   5 : Privilèges forum : peut créer un sujet et répondre
  #   1 : Son mail a été confirmé
  #   0 : Il n'a pas été détruit
  r.set(options: '0510')
  # On vérifie que les options ont bien été enregistrées
  checkr = row(duser[:id])
  checkr.has(options: '0510')
  show "Options de l'user réglées pour bons privilèges."

end

# ---------------------------------------------------------------------
#   RÉGLAGE DE L'USER
#   Pour qu'il ait suffisamment de privilège pour faire toutes les
#   expérience
# ---------------------------------------------------------------------


# TODO Test sur le forum
# L'user écrit un message sur le forum
# Le message est affiché
# L'user est détruit

# ON DÉTRUIT L'USER

require './objet/user/destroy.rb'
test_user duser[:id] do
  proceed_destruction # dans le module destroy.rb ci-dessus
end

# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
#   APRÈS DESTRUCTION DE L'USER
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------

# TODO Son dossier de user ne doit plus exister
# dans les données
test_user duser[:id] do

  # L'user ne doit plus répondre positivement à exist?
  is_exist(sujet: 'L’user')
  is_destroyed(sujet: 'L’user')

  # Son bit de destruction doit être activé
  options[3].is('1', sujet: "Le bit de marque de destruction de l'user")

end
