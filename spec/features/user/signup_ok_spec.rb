require 'digest/md5'
feature "Inscription d'un nouveau membre" do
  scenario "Un nouveau membre s'inscrit avec succès" do

    start_time = Time.now.to_i

    nombre_users = User::table_users.count.freeze

    visit home

    click_link "S'inscrire"

    expect(page).to have_titre("Inscription")
    expect(page).to have_formulaire('form_user_signup')
    puts "La page possède le formulaire d'inscription"

    # Il remplit le formulaire avec de bonnes valeurs
    mail          = "unmail#{Time.now.to_i}@chez.lui"
    mot_de_passe  = "unmotdepassecorrect"
    data = {
      mail:mail, mail_confirmation:mail,
      password:mot_de_passe, password_confirmation:mot_de_passe,
      pseudo:"Pseudo#{Time.now.to_i}",
      patronyme:"Patro De#{Time.now.to_i}",
      captcha: "365"
    }
    within("form#form_user_signup") do
      data.each do |k, val|
        fill_in( "user[#{k}]", with: val)
      end
      select("une femme", from: "user[sexe]")
      click_button "S'inscrire"
    end

    # On doit se trouver sur la page ?
    # Page d'arrivée conforme
    expect(page).to have_titre("Vous êtes inscrite !")

    new_nombre_users = User::table_users.count.freeze
    expect(new_nombre_users).to eq nombre_users + 1
    puts "Il y a un auteur en plus"

    last_user = User::table_users.select(limit:1, order:"created_at DESC").values.first

    expect(last_user[:pseudo]).to eq data[:pseudo]
    expect(last_user[:patronyme]).to eq data[:patronyme]
    expect(last_user[:mail]).to eq data[:mail]
    expect(last_user[:cpassword]).to eq Digest::MD5.hexdigest("#{mot_de_passe}#{mail}#{last_user[:salt]}")
    expect(last_user[:sexe]).to eq "F"
    puts "Les données sont valides dans la base de données"

    # Non validé
    expect(last_user[:options][2].to_i).to eq 0
    puts "L'auteur n'est pas encore validé"

    # Un mail de confirmation lui a été envoyé
    user = User::get(last_user[:id])

    expect(user).to have_mail_with(
      sent_after:     start_time,
      subject:        "Confirmez votre inscription"
    )
    puts "Un mail lui est envoyé pour confirmer son inscription"
  end
end
