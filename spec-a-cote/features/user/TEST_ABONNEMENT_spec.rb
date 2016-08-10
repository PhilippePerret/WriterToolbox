# encoding: UTF-8
=begin

  Test complet d'un abonnement, entièrement piloté.

  Le test procède au paiement sur le site PayPal de l'abonnement.

  Le test procède à :

    - l'inscription de l'user
    - la confirmation du mail de l'user


  Le test s'assure que :

    - l'user soit bien inscrit
    - que son mail ait bien été confirmé
    - qu'un message de bienvenue soit envoyé
    - qu'un mail de facture ait été envoyé
    - qu'un mail d'annonce de l'inscription a été envoyé à l'administration
    - qu'un mail d'annonce de l'abonnement a été envoyé à l'administration
    - qu'une autorisation d'un an ait été accordée à l'user

=end
feature "Test d'un abonnement à la boite à outils" do
  scenario "Un visiteur peut s'inscrire et prendre un abonnement" do

    remove_users :all

    # Nombre actuelle d'autorisation
    nombre_autorisations = User.table_autorisations.count.freeze
    puts "Nombre d'autorisations au départ : #{nombre_autorisations}"

    start_time = Time.now.to_i
    data = random_user_data
    pseudo = data[:pseudo]

    is_femme = data[:sexe] == 'F'

    IL      = is_femme ? 'Elle' : 'Il'
    UN_USER = is_femme ? 'une useuse' : 'un user'
    E       = is_femme ? 'e' : ''

    puts "#{UN_USER.capitalize} nommé#{E} #{pseudo} rejoint le site le #{start_time.as_human_date(true, true, ' ', 'à')}"
    visit home

    puts "#{IL} rejoint le formulaire d'inscription pour s'inscrire…"
    click_link "S'inscrire"
    fill_signup_form_with data, {abonnement: true, submit: true}
    shot("after-signup")


    # On récupère l'auteur et on en fait une instance User dans `u`
    duser = User.table.select(limit:1, order:"created_at DESC").first
    u     = User.new(duser[:id])
    puts "#{pseudo} s'est inscrit#{E} avec succès !"

    # === L'user confirme son adresse mail ===
    puts "#{pseudo} utilise son ticket pour confirmer son mail…"
    expect(u.mail_confirmed?).to eq false
    site.require_module 'ticket'
    hticket = app.table_tickets.select(where:{user_id: u.id}, limit:1, order:"created_at DESC").first
    ticket_id = hticket[:id]
    visite_route "site/home?tckid=#{ticket_id}"
    u = User.new(duser[:id])
    $users_2_destroy << u.id
    expect(u.mail_confirmed?).to eq true
    puts "Le mail de #{pseudo} est confirmé !"

    # === L'user s'abonne ===
    puts "#{pseudo} clique le formulaire Paypal…"
    visite_route 'user/paiement'
    expect(page).to have_css("form##{FORM_PAYPAL_ID}")
    expect(page).to have_tag('form', with: {id: FORM_PAYPAL_ID})
    # Le token créé pour ce paiement
    # Je le crée vraiment, pour qu'il puisse être enregistré
    # et plus tard je saurai peut-être vraiment procéder au
    # paiment
    token = page.find("form##{FORM_PAYPAL_ID} input[name=\"token\"]", visible: false).value
    puts "Le token de la transaction est : #{token.inspect}"

    puts "#{pseudo} clique sur le formulaire PayPal et attend…"
    page.find("form##{FORM_PAYPAL_ID}").click
    sleep 2
    until page.has_css?('body')
      puts "J'attends que la page réapparaisse…"
      sleep 1
    end
    sleep 2

    require './data/secret/data_benoit'

    puts "#{IL} remplit le formulaire PayPal avec ses données…"
    code_javascript = <<-JS
var iframe;
for(iframe = 0; iframe < 4; ++iframe){
  if(window.frames[iframe].document.getElementById('email')){break}
}
var doc = window.frames[iframe].document;
doc.getElementById('email').value='#{DATA_BENOIT[:mail]}';
doc.getElementById('password').value='#{DATA_BENOIT[:password]}';
doc.getElementById('btnLogin').click();
    JS
    page.execute_script(code_javascript.gsub(/\n/,''))
    puts "#{pseudo} attend de pouvoir confirmer le paiement…"
    sleep 2
    until page.has_css?('body')
      puts "J'attends que la page pour continuer apparaissent…"
      sleep 1
    end
    puts "#{IL} attend 6 secondes"
    js_attente = "return document.getElementById('continue_abovefold');"
    while page.execute_script(js_attente) == nil
      sleep 0.5
    end
    puts "Le bouton a été trouvé"
    sleep 2
    shot 'page-paypal-continuer'
    puts "#{pseudo} clique le bouton “Continuer” pour procéder au paiement"
    require 'timeout'
    Timeout::timeout(20*60) do
      # Je hacke un peu... pour essayer d'attendre sans erreur si c'est
      # trop long.
      page.execute_script('document.getElementById("continue_abovefold").click()')
      puts "#{pseudo} attend qu'on revienne de PayPal…"
    end
    until page.has_css?('section#footer')
      sleep 1
    end
    shot 'retour-site-after-paiement'

    expect(page).to have_content( "MERCI, #{pseudo} !")
    puts "#{pseudo} trouve le message de confirmation !"
    expect(page).not_to have_css('#flash div.error')
    puts "Aucune erreur ne s'est produite !"

    # On attend un peu que tout ait été fait
    sleep 2


    # ---------------------------------------------------------------------
    # Normalement, ici, l'inscription est terminée

    # Un mail a été envoyé à l'user pour confirmer son paiement
    expect(u).to have_mail(
      sent_after:   start_time,
      subject:      'Confirmation de votre paiement',
      message:      ["Bonjour #{pseudo}", 'facture pour votre dernier paiement']
    )
    puts "#{pseudo} a reçu un mail confirmant son paiement, avec sa facture"
    # # TODO Un mail a été envoyé à l'admin pour informer de l'abonnement
    # Apparemment, il n'y a pas d'envoi… bizarre…
    # puts MailMatcher.mails_found.pretty_inspect

    puts "L'administration doit recevoir un mail annonçant la nouvelle inscription…"
    expect(phil).to have_mail(
      sent_after:   start_time,
      subject:      'Nouvelle inscription',
      message:      [pseudo, "##{duser[:id]}"]
    )

    puts "L'administration doit recevoir un mail annonçant le paiement…"
    expect(phil).to have_mail(
      sent_after:   start_time,
      subject:      'Nouvel abonnement au site',
      message:      [pseudo, "##{duser[:id]}", "Facture envoyée"]
    )

    puts "Mails pour l'administrateur trouvés !"

    # Le nouvel abonné doit avec une autorisation
    puts "#{pseudo} doit posséder une autorisation dans la table…"
    puts "Nombre d'autorisations après paiement : #{User.table_autorisations.count}"
    expect(User.table_autorisations.count).to eq nombre_autorisations + 1
    expect(User.table_autorisations.count(where:{user_id: u.id})).to eq 1
    puts "Il y a une nouvelle autorisation et elle appartient à #{pseudo}"
    # Une autorisation doit avoir été créée pour l'auteur
    dautos = User.table_autorisations.select(where: {user_id: u.id})
    expect(dautos).not_to be_empty
    dauto = dautos.first
    expect(dauto[:raison]).to eq 'ABONNEMENT'
    expect(dauto[:end_time]).not_to eq nil
    expect(dauto[:end_time]).to be > (start_time + 1.year - 1000)
    puts "L'autorisation de #{pseudo} est conforme !"

  end
end
