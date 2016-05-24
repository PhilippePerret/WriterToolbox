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

MD

let(:start_time){ Time.now.to_i - 1 }

let(:user_mail){ 'unfakemail@yahoo.fr' }
let(:user_pwd){ 'unmotdepassevalide' }
duser = {
  id:       nil,
  pseudo:   "UnPseudoPourUneUseuse",
  mail:     get(:user_mail),
  password: get(:user_pwd)
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
    user_captcha: {name: 'user[captcha]', value: '366'}
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

# Création du programme UN AN UN SCRIPT pour l'user
# TODO (VOIR CE QUI SE PASSE APRÈS QUE L'USER A PAYÉ)

# ---------------------------------------------------------------------
#   RÉGLAGE DE L'USER
#   Pour qu'il ait suffisamment de privilège pour faire toutes les
#   expérience
# ---------------------------------------------------------------------


# TODO Test sur le forum
# L'user écrit un message sur le forum
# Le message est affiché
# L'user est détruit



# PROGRAMME UN AN UN SCRIPT (avant destruction)
# -------------------------

# Inscription au programme UN AN UN SCRIPT
site.require_objet 'unan'
(Unan::folder_modules + 'signup_user.rb').require
User.get(duser[:id]).signup_program_uaus

test_user duser[:id] do

  # Il doit être inscrit
  unanunscript?.is true

  # Il doit avoir un programme
  program.is_not nil

end
# TODO TEST : On doit voir le programme quelque part, dans une
# liste qui affiche les programmes
# TODO TEST : Les options du programme doivent être :
#   options[0] = '1' (programme actif)
#   options[2] = '0' (ou rien) (programme non abandonné)

# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------

# TODO ON DÉTRUIT L'USER

# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
#   APRÈS DESTRUCTION DE L'USER
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------

# PROGRAMME UN AN UN SCRIPT
# -------------------------
# TODO On ne doit plus voir le programme de user dans la liste des
# programmes UN AN UN SCRIPT
# TODO TEST : Le programme doit être marqué interrompu (abandonné)
# options[0] doit être à '0' (programme inactif)
# options[2] doit être à '1' (programme abandonné)
# TEST : Le projet doit être marqué interrompu aussi ? Non, il n'existe
# pas d'indication pour le projet.

# FORUM
# ------
# TODO TEST : Le message n'est plus affiché (un texte type à la place)
# TODO TEST : Le message existe toujours
