# encoding: UTF-8
feature "Test d'un abonnement à la boite à outils" do
  scenario "Un visiteur peut s'inscrire et prendre un abonnement" do

    start_time = Time.now.to_i
    pseudo = random_pseudo

    puts "Un user nommé #{pseudo} rejoint le site le #{start_time.as_human_date(true, true, ' ', 'à')}"

    visit home
    puts "Il rejoint le formulaire d'inscription et s'inscrit…"
    click_link "S'inscrire"
    mail          = "#{pseudo}#{Time.now.to_i}@chez.lui"
    mot_de_passe  = "unmotdepassecorrect"
    data = {
      pseudo:       pseudo,
      patronyme:    "Patro De#{Time.now.to_i}",
      mail:         mail,
      mail_confirmation:mail,
      password:     mot_de_passe,
      password_confirmation:mot_de_passe,
      captcha:      "366"
    }
    within("form#form_user_signup") do
      data.each do |k, val|
        fill_in( "user[#{k}]", with: val)
      end
      select("une femme", from: "user[sexe]")
      click_button "S'inscrire"
    end
    shot("after-signup")


    # On récupère l'auteur et on en fait une instance User dans `u`
    duser = User.table.select(limit:1, order:"created_at DESC").first
    u     = User.new(duser[:id])
    puts "#{pseudo} s'est inscrit avec succès"

    # === L'user confirme son adresse mail ===
    puts "#{pseudo} confirme son mail grâce au ticket"
    expect(u.mail_confirmed?).to eq false
    site.require_module 'ticket'
    hticket = app.table_tickets.select(where:{user_id: u.id}, limit:1, order:"created_at DESC").first
    ticket_id = hticket[:id]
    visite_route "site/home?tckid=#{ticket_id}"
    u = User.new(duser[:id])
    $users_2_destroy << u.id
    expect(u.mail_confirmed?).to eq true
    puts "Le mail de l'user est confirmé"

    # === L'user s'abonne ===
    puts "#{pseudo} s'abonne"
    visite_route 'user/paiement'
    sleep 10
    expect(page).not_to have_css('#flash div.error')
    expect(page).to have_css('form#form_paiement')
    # Le token créé pour ce paiement
    # Je le crée vraiment, pour qu'il puisse être enregistré
    # et plus tard je saurai peut-être vraiment procéder au
    # paiment
    token =
      within('form#form_paiement') do
        find('input[type="hidden"][name="token"]', visible: false).value
      end

    # Pour le moment, on simule le paiement paypal en se rendant
    # directement à l'adresse.
    # Mais avant, il faut créer un enregistrement du paiement pour
    # que ça fonctionne
    now = Time.now.to_i
    User.table_paiements.insert(
      user_id:    u.id,
      objet_id:   'ABONNEMENT',
      montant:    site.tarif,
      facture:    token,
      created_at: now
    )
    visite_route "paiement/on_ok"

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
    expect(phil).to have_mail(
      sent_after:  start_time
    )
    puts "Les mails pour l'administrateur trouvés"
    puts MailMatcher.mails_found.pretty_inspect

    # Le nouvel abonné doit avec une autorisation
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
    puts "L'autorisation est tout à fait conforme"

  end
end
