feature "Inscription non valide au site" do
  def set_in_form hdata
    within("form#form_user_signup") do
      hdata.each do |prop, val|
        fill_in "user[#{prop}]", with: val
      end
      click_button "S'inscrire"
    end
  end
  scenario "Impossible de s'inscrire au site sans aucune données" do

    start_time = Time.now.to_i
    nombre_users = User::table_users.count.freeze

    visit home
    click_link "S'inscrire"
    expect(page).to have_titre "Inscription"

    set_in_form({})
    expect(page).to have_error "Il faut fournir le pseudo."

  end
  scenario 'Impossible de s’inscrire au site avec de mauvaises données' do

    start_time = Time.now.to_i
    nombre_users = User::table_users.count.freeze

    visit home
    click_link "S'inscrire"
    expect(page).to have_titre "Inscription"

    set_in_form({pseudo: "Phil"})
    expect(page).to have_error "Ce pseudo est déjà utilisé, merci d'en choisir un autre"

    set_in_form(pseudo: "a"*41)
    expect(page).to have_error "Le pseudo doit faire moins de 40 caractères."

    set_in_form(pseudo: "Pi")
    expect(page).to have_error "Le pseudo doit faire au moins 3 caractères."

    pseudo = random_pseudo
    data = { pseudo:pseudo, patronyme:"" }

    set_in_form( data )
    expect(page).to have_error "Il faut fournir le patronyme."

    set_in_form(data.merge(patronyme: "abcb "*52))
    expect(page).to have_error "Le patronyme ne doit pas faire plus de 255 caractères."

    set_in_form(data.merge(patronyme: "Pi"))
    expect(page).to have_error "Le patronyme ne doit pas faire moins de 3 caractères."

    data.merge!(patronyme: "Pseudo De#{NOW} Lui", mail:"")

    set_in_form(data.merge(mail:""))
    expect(page).to have_error "Il faut fournir votre mail."

    set_in_form(data.merge(mail:"A"*256))
    expect(page).to have_error "Ce mail est trop long."

    ['badformat', 'bad @ format', 'bad@format', 'bad@format.pourunemavais', 'bad!format@mais.com'].each do |badmail|
      set_in_form(data.merge(mail:badmail))
      expect(page).to have_error "Ce mail n'a pas un bon format de mail."
    end

    mail_bad = User::table.get(1, colonnes:[:mail])[:mail]
    set_in_form(data.merge( mail: mail_bad ))
    expect(page).to have_error "Ce mail existe déjà… Vous devez déjà être inscrit…"

    mail = "bon_mail@pour.voir"
    data.merge!(mail:mail)

    set_in_form(data.merge(mail_confirmation:""))
    expect(page).to have_error "La confirmation du mail ne correspond pas."

    set_in_form(data.merge(mail_confirmation:"bad_mail@pour.voir"))
    expect(page).to have_error "La confirmation du mail ne correspond pas."

    set_in_form(data.merge(mail_confirmation:"bon_mail-@pour.voir"))
    expect(page).to have_error "La confirmation du mail ne correspond pas."

    data.merge!(mail_confirmation:mail)

    # ---------------------------------------------------------------------
    #   Mot de passe
    #
    set_in_form(data.merge(password:""))
    expect(page).to have_error "Il faut fournir un mot de passe."

    set_in_form(data.merge(password:"ab"*22))
    expect(page).to have_error "Le mot de passe ne doit pas excéder les 40 caractères."

    set_in_form(data.merge(password:"abcdefg"))
    expect(page).to have_error "Le mot de passe doit faire au moins 8 caractères."

    data.merge!(password:"abcdefghij")

    # ---------------------------------------------------------------------
    #   Confirmation du mot de passe
    #
    set_in_form(data.merge(password_confirmation:""))
    expect(page).to have_error "La confirmation du mot de passe ne correspond pas."

    set_in_form(data.merge(password_confirmation:"bcdefghij"))
    expect(page).to have_error "La confirmation du mot de passe ne correspond pas."

    data.merge!(password_confirmation:"abcdefghij")

    # ---------------------------------------------------------------------
    #   Captcha
    set_in_form(data.merge(captcha:""))
    expect(page).to have_error "Il faut fournir le captcha pour nous assurer que vous n'êtes pas un robot."

    set_in_form(data.merge(captcha:"364"))
    expect(page).to have_error "Le captcha est mauvais, seriez-vous un robot ?"

    set_in_form(data.merge(captcha:"trois cent soixante six"))
    expect(page).to have_error "Le captcha est mauvais, seriez-vous un robot ?"

    # ---------------------------------------------------------------------
    # Aucun nouveau user n'a été créé
    expect(User::table_users.count).to eq nombre_users

    # Maintenant, tout doit passer
    set_in_form(data.merge(captcha:"366"))

    # Ça a dû marcher
    expect(User::table_users.count).to eq ( nombre_users + 1 )

  end
end
