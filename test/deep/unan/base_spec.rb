# encoding: UTF-8

description <<-MD
Test de la base du fonctionnement du programme UN AN UN SCRIPT.

Dans ce premier module, on simule l'inscription d'un nouvel inscrit.
MD

start_time = Time.now.to_i - 1

test_route "unan/paiement" do
  description "On peut rejoindre le formulaire d'inscription au programme UN AN UN SCRIPT."
  responds
  html.has_title('Inscription au programme')
  html.has_tag('form#form_user_signup')
  # En revanche, on doit trouver un champ caché qui indique que
  # l'user veut s'inscription au programme
  html.has_tag('input[type="checkbox"]#user_subscribe', {checked:'CHECKED'})
  html.has_tag('label', {for: 'user_subscribe', text: "S'abonner au programme UN AN UN SCRIPT"})
end

duser = {
  id:     nil,
  pseudo: 'MonPseudoPourUNAN',
  mail:   'ut10739@gmail.com',
  pwd:    "un#{Time.now.to_i}motdepasse"
}
dform = {
  id: 'form_user_signup',
  fields:{
    user_pseudo:  {name: 'user[pseudo]',    value: duser[:pseudo]},
    user_patro:   {name: 'user[patronyme]', value: duser[:pseudo]},
    user_mail:    {name: 'user[mail]',   value: duser[:mail]},
    umail_conf:   {name: 'user[mail_confirmation]', value: duser[:mail]},
    user_code:    {name: 'user[password]', value: duser[:pwd]},
    ucode_conf:   {name: 'user[password_confirmation]', value: duser[:pwd]},
    user_sexe:    {name: 'user[sexe]', value:'F'},
    capcha:       {name: 'user[captcha]', value: '366'},
    subscribe:    {name: 'user[subscribe]', value: 'on'}
  }
}

test_form 'unan/create', dform do
  description "Remplissage et soumission du formulaire d'inscription au programme UN AN UN SCRIPT"
  fill_and_submit
  curl_request.header.has(status_code: 200)
  html.has_not_tag('form#form_user_signup')
  html.has_not_error
  # html.debug_debug
  # La page contient le formulaire pour procéder au paiement
  # paypal
  html.has_tag('form#form_paiement')
  # debug "HTML : #{html.inspect}"
end

# Là il faudrait faire comme si on passer par Paypal
test_route 'paiement/on_ok?in=unan' do
  description "Simulation du retour PayPal OK (création du programme pour l'user)"
  responds
  html.has_title('C\'est parti !')
end


# On va récupérer le dernier utilisateur créé, qui doit correspond
test_base 'users.users' do
  du = row(mail: duser[:mail])
  du.exists
  du = du.data
  du[:id].is_not(nil, sujet: 'L’identifiant du nouvel inscrit')
  duser[:id] = du[:id]
  show "User ID : #{du[:id]}"
end
# Ensuite, on peut vérifier que l'user a bien tout ce qu'il faut

site.require_objet('unan')

test_user duser[:id] do
  description "Les données de l'user doivent être correctes"
  # show duser.inspect
  id.is_not(nil, 'L’identifiant de l’user')
  program.is_not(nil, 'La propriété `program`')
  is_identified
  if subject.identified?
    is_unanunscript
  else
    show "Je ne peux pas vérifier s'il est inscrit par unanunscript? car il n'est pas identifié."
  end
end

# login_user duser[:id], {password: duser[:password]}


# test_user duser[:id] do
#   description "L'user a reçu les mails attendus"
#   has_mail(
#     sujet: "Bienvenue sur le programme UN AN UN SCRIPT",
#     sent_after:  start_time
#   )
#   pending_
# end
#
# test_route "unan/home" do
#   description "L'user trouve son bureau de travail"
#   responds
#   pending_
# end
