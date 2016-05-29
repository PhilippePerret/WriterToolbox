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



# PROGRAMME UN AN UN SCRIPT (avant destruction)
# -------------------------

# Inscription au programme UN AN UN SCRIPT
site.require_objet 'unan'
(Unan::folder_modules + 'signup_user.rb').require
User.get(duser[:id]).signup_program_uaus

test_user duser[:id] do

  # Il doit être inscrit au programme un an un script
  unanunscript?.is(true, sujet: "unanunscript? de l'user")

  # Il doit avoir un programme
  program.is_not(nil, sujet: "La propriété `program` de l'user")
  program.is_instance_of(Unan::Program, sujet: "La classe du programme")

  let(:program_id){ program.id }
  duser.merge!(
    program_id: program.id,
    projet_id:  program.projet.id
    )

  projet.id.is_not(nil, sujet: 'L’ID du projet')
  show "PROJET_ID : #{duser[:projet_id].inspect}"

  # Il doit avoir un dossier et un fichier pour son nouveau
  # programme
  tfolder("./database/data/unan/user/#{duser[:id]}").exists
  tfile("./database/data/unan/user/#{duser[:id]}/programme#{program.id}.db").exists

end

test_base "unan_hot.programs" do
  progid = tget(:program_id)
  show "PROGRAM ID = #{progid.inspect}"
  show "tget(:program_id) = #{tget(:program_id).inspect}"

  # On vérifie que les options soient bien réglées
  #   options[0] = '1' (programme actif)
  #   options[2] = '0' (ou rien) (programme non abandonné)
  opts = row(duser[:program_id]).data[:options]
  show "Options du programme de l'user : #{opts.inspect}"
  opts[0].is('1', sujet: 'Le premier bit d’options (actif)')
  opts[2].is_not('1', sujet: 'Le troisième bit d’options (abandon)')
end


# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------

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

  # Il ne doit plus avoir de dossier dans les
  # data
  tfile("./database/data/unan/user/#{duser[:id]}/programme#{duser[:program_id]}.db", 'La base de donnée du programme UN AN UN SCRIPT').not_exists
  tfolder("./database/data/unan/user/#{duser[:id]}", 'Le dossier du programme UN AN UN SCRIPT').not_exists

end

# PROGRAMME UN AN UN SCRIPT
# -------------------------
test_user duser[:id] do
  program.is(nil)
end

test_base 'unan_hot.programs' do
  # La liste des programmes ne doit plus contenir le
  # programme de l'user
  row(id: duser[:program_id]).not_exists
end

test_base 'unan_hot.projets' do
  row( id: duser[:projet_id] ).not_exists
end

test_base 'unan_archives.programs' do
  description 'Vérification des options du programme dans les archives'
  # Le programme doit avoir été mis dans les archives
  # Le programme ne doit plus être actif
  opts = row(id: duser[:program_id]).data[:options]
  opts[0].is('0', 'Le bit de programme actif')
  # Le programme doit avoir été marqué abandonné
  opts[2].is('1', 'Le bit de programme abandonné')
end
test_base 'unan_hot.projets' do
  description 'Le projet n’est plus dans les données courantes'
  row(duser[:projet_id]).not_exists
end
test_base 'unan_archives.projets' do
  description 'Vérification de la présence des données projets dans les archives de projets.'
  # Le projet doit avoir été mis dans les archives
  row(id: duser[:projet_id]).exists
end



# FORUM
# ------
# TODO TEST : Le message n'est plus affiché (un texte type à la place)
# TODO TEST : Le message existe toujours
