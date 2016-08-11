require 'digest/md5'
feature "Inscription d'un nouveau membre" do

  scenario "Un nouveau membre s'inscrit avec succès" do

    start_time = Time.now.to_i - 1

    nombre_users = User.table_users.count.freeze
    nombre_autorisations = User.table_autorisations.count.freeze

    visit home

    click_link "S'inscrire"

    expect(page).to have_titre("Inscription")
    expect(page).to have_formulaire('form_user_signup')
    puts "La page possède le formulaire d'inscription"

    # Il remplit le formulaire avec de bonnes valeurs
    mail          = "unmail#{Time.now.to_i}@chez.lui"
    mot_de_passe  = "unmotdepassecorrect"
    data = {
      pseudo: random_pseudo,
      patronyme:"Patro De#{Time.now.to_i}",
      mail:mail, mail_confirmation:mail,
      password:mot_de_passe, password_confirmation:mot_de_passe,
      captcha: "366"
    }
    within("form#form_user_signup") do
      data.each do |k, val|
        fill_in( "user[#{k}]", with: val)
      end
      select("une femme", from: "user[sexe]")
      click_button "S'inscrire"
    end

    shot("after-signup")

    # On doit se trouver sur la page ?
    # Page d'arrivée conforme
    expect(page).to have_titre("Vous êtes inscrite !")

    new_nombre_users = User::table_users.count.freeze
    expect(new_nombre_users).to eq nombre_users + 1
    puts "Il y a un auteur en plus"


    last_user = User::table_users.select(limit:1, order:"created_at DESC").first

    expect(last_user[:pseudo]).to eq data[:pseudo]
    expect(last_user[:patronyme]).to eq data[:patronyme]
    expect(last_user[:mail]).to eq data[:mail]
    expect(last_user[:cpassword]).to eq Digest::MD5.hexdigest("#{mot_de_passe}#{mail}#{last_user[:salt]}")
    expect(last_user[:sexe]).to eq "F"
    puts "Les données sont valides dans la base de données"

    # Non validé
    expect(last_user[:options][2].to_i).to eq 0
    puts "L'auteur n'est pas encore validé"

    # Le dernier user créé donc celui-ci
    u = User.get(last_user[:id])

    # Un ticket a été créé pour lui
    site.require_module 'ticket'
    res = app.table_tickets.select(where:{user_id: last_user[:id]}, limit:1, order:"created_at DESC").first
    expect(res).not_to eq nil
    expect(res[:created_at]).to be >= start_time
    ticket_id_in_table = res[:id]
    puts "Un ticket a été créé pour l'user avec les bonnes données"

    expect(u).to have_mail(
      sent_after:     start_time,
      subject:        'Merci de confirmer votre mail'
    )
    puts "Un mail lui est envoyé pour confirmer son inscription"

    mail_user = MailMatcher::mails_found.first
    # => Instance MailMatcher

    # puts mail_user.pretty_inspect
    message = mail_user.message_content
    expect(message).to include "confirmer votre adresse-mail"
    puts "Le mail contient le bon message"
    ticket_id = message.match(/\?tckid\=([a-zA-Z0-9]+)/).to_a[1]
    puts "ID du ticket dans le message : #{ticket_id}"
    expect(ticket_id).to eq ticket_id_in_table
    puts "Le ticket contenu dans le mail correspond au numéro de ticket dans la table"

    # ---------------------------------------------------------------------
    # Test de l'autorisation

    # Il NE doit PAS y avoir une autorisation de plus, puisque
    # c'est ici une simple inscription, sans abonnement
    expect(User.table_autorisations.count).to eq nombre_autorisations
    expect(User.table_autorisations.count(where:{user_id: u.id})).to eq 0

  end
end
