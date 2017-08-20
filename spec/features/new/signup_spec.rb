
require_integration_support
require_db_support


# Retourne un Hash avec les données d'un nouvel utilisateur
def data_new_user params = nil
  params ||= {}
  sleep 0.1
  now = Time.now.to_i
  mail      = params[:mail]     || "mail#{now}@chezlui.com"
  password  = params[:password] || 'unmotdepassequelconque'
  {
    pseudo:                 params[:pseudo]     || "Pseudo#{now}",
    patronyme:              params[:patronyme]  || "Pseudo#{now} Patro",
    sexe:                   params[:sexe]       || 'H',
    mail:                   mail,
    mail_confirmation:      mail,
    password:               password,
    password_confirmation:  password,
    captcha:                params[:captcha]    || '366'
  }
end

# Fait une tentative d'inscription
# return {Hash} Les données du nouvel utilisateur
#
def try_signup_with_data nuser_data
  remove_mails
  visit signup_page
  within('form#form_user_signup') do
    nuser_data.each do |k, v|
      k != :sexe || next
      fill_in "user_#{k}", with: v
    end
    select(nuser_data[:sexe] == 'H' ? 'un homme' : 'une femme', from: 'user_sexe')
    # TODO Pour s'abonner, la case à cocher
    click_button 'S\'inscrire'
    shot "inscription-de-#{nuser_data[:pseudo]}"
  end
  # For convenience
  return nuser_data
end


feature "Un utilisateur quelconque" do

  before(:all) do

    # On détruit toutes les données des utilisateurs, SAUF les
    # données des administrateurs
    truncate_table_users

  end

  scenario "=> peut rejoindre le formulaire d'inscription à partir de l'accueil" do
    visit home_page
    expect(page).to have_link('S\'inscrire')
    click_link 'S\'inscrire'
    expect(page).to have_tag('form#form_user_signup')
  end

  scenario '=> peut s’inscrire avec des données valides' do
    start_time = Time.now.to_i
    sleep 0.01
    data_user = try_signup_with_data( data_new_user )
    expect(page).not_to have_tag('div.error')
    expect(page).to have_tag('h1', text:'Vous êtes inscrit !')
    expect(page).to have_content("#{data_user[:pseudo]}, heureux de vous compter parmi les utilisateurs de La Boite à Outils de L'Auteur")
    expect(page).to have_tag('a', with:{href: 'user//paiement'}, text: 'vous abonner pour un an')
    success "  L'utilisateur a été redirigé vers une page de confirmation valide"

    dbuser = db_get_user_by_pseudo(data_user[:pseudo])
    expect(dbuser[:id]).to eq 51
    expect(dbuser[:pseudo]).to eq data_user[:pseudo]
    expect(dbuser[:mail]).to eq data_user[:mail]
    expect(dbuser[:created_at]).to be > start_time
    expect(dbuser[:options]).to eq '0000000000'
    success "  L'utilisateur a été créé dans la base de données avec des données valides"
    # Calcul du mot de passe crypté
    require 'digest/md5'
    expected_crypted_pwd = Digest::MD5.hexdigest("#{data_user[:password]}#{data_user[:mail]}#{dbuser[:salt]}")
    success "  Le mot de passe de #{data_user[:pseudo]} a bien été crypté."


    # Mails envoyés
    u = User.new(dbuser.merge(password: data_user[:password]))

    # puts "Mail de l'user : #{data_user[:mail]}"
    # puts "Tous les mails:\n#{MailMatcher::all_mails.inspect}"

    u.a_recu_le_mail({
      subject: 'Bienvenue',
      message: [
        "#{data_user[:pseudo]}, bienvenue",
        "Vous vous êtes inscrit avec le mail",
        "#{data_user[:mail]}"
      ],
      success: "  Un mail de confirmation d'inscription a été envoyé à l'utilisateur"
    })

    # Vérification du mail de bienvenue
    hticket = db_get_ticket_with(code: "User::get(51).confirm_mail", user_id: 51)
    u.a_recu_le_mail({
      subject: 'Merci de confirmer votre mail',
      message: [
        "Merci de bien vouloir confirmer votre adresse-mail",
        "<p><a href=\"http://www.laboiteaoutilsdelauteur.fr\?tckid=#{hticket[:id]}\">Confirmation de votre mail</a></p>"
      ],
      success: "  Un mail de demande de confirmation de mail a été envoyé à l'utilisateur"
      })

    # Vérification du mail d'information à l'administration
    admin = User.new({mail: 'phil@laboiteaoutilsdelauteur.fr', pseudo:'Phil', id: 1})
    admin.a_recu_le_mail({
      subject: "Nouvelle inscription",
      message: [
        "je t'informe d'une nouvelle inscription",
        "#{data_user[:mail]}",
        "#{data_user[:pseudo]}"
      ],
      success: "  Un mail d'information a été envoyé à l'administration du site"
      })

  end
end
feature "Un visiteur quelconque ne peut pas s'inscrire…" do
  scenario 'sans pseudo' do
    try_signup_with_data( data_new_user(pseudo: ''))
    expect(page).to have_tag('div.error', text: /Il faut fournir votre pseudo/)
  end
  scenario 'avec un pseudo trop long' do
    try_signup_with_data( data_new_user(pseudo: 'p'*40))
    expect(page).to have_tag('div.error', text: /Ce pseudo est trop long/)
  end
  scenario 'avec un pseudo trop court' do
    try_signup_with_data( data_new_user(pseudo: 'pp'))
    expect(page).to have_tag('div.error', text: /Ce pseudo est trop court/)
  end
  scenario 'avec un pseudo contenant des caracètres interdit' do
    try_signup_with_data( data_new_user(pseudo: '?!pour voir&revoir'))
    expect(page).to have_tag('div.error', text: /Ce pseudo est invalide/)
  end
  scenario 'avec un pseudo existant' do
    try_signup_with_data( data_new_user(pseudo: 'Phil'))
    expect(page).to have_tag('div.error', text: /Ce pseudo est déjà utilisé/)
  end
  scenario 'sans patronyme' do
    try_signup_with_data( data_new_user(patronyme: ''))
    expect(page).to have_tag('div.error', text: /Il faut fournir votre patronyme/)
  end
  scenario 'avec un patronyme trop long' do
    try_signup_with_data( data_new_user(patronyme: "#{'p'*100} #{'p'*254}"))
    expect(page).to have_tag('div.error', text: /Le patronyme est trop long/)
  end
  scenario 'avec un patronyme trop court' do
    try_signup_with_data( data_new_user(patronyme: "pp"))
    expect(page).to have_tag('div.error', text: /Le patronyme est trop court/)
  end
  scenario 'avec un mail existant' do
    try_signup_with_data( data_new_user(mail: 'phil@laboiteaoutilsdelauteur.fr'))
    expect(page).to have_tag('div.error', text: /Ce mail existe déjà/)
  end
  scenario 'avec une confirmation de mail invalide' do
    try_signup_with_data( data_new_user.merge(mail_confirmation: 'mauvaiseconfirmation'))
    expect(page).to have_tag('div.error', text: /La confirmation du mail ne correspond pas/)
  end
  scenario 'avec une confirmation de mot de passe invalide' do
    try_signup_with_data( data_new_user.merge(password_confirmation: 'mauvaiseconfirmation'))
    expect(page).to have_tag('div.error', text: 'La confirmation du mot de passe ne correspond pas.')
  end
  scenario 'sans captcha' do
    try_signup_with_data( data_new_user(captcha: '') )
    expect(page).to have_tag('div.error', text: /Il faut fournir le captcha/)
  end
  scenario 'sans un captcha valide' do
    try_signup_with_data( data_new_user(captcha: '100') )
    expect(page).to have_tag('div.error', text: /Le captcha est mauvais/)
  end

end


feature "Un visiteur qui vient de s'inscrire avec succès" do
  before(:all) do
    # On détruit toutes les données des utilisateurs, SAUF les
    # données des administrateurs
    truncate_table_users
  end

  scenario "=> peut lire la description du programme UAUS" do
    try_signup_with_data( data_new_user )
    expect(page).to have_tag('a', with: {id: 'link_to_prog_uaus'}, text: 'programme UNANUNSCRIPT')
    expect(page).to have_link 'programme UNANUNSCRIPT'
    click_link 'programme UNANUNSCRIPT'
    success '  L’user peut cliquer le lien vers le programme UAUS'
    expect(page).to have_tag('h1') do
      with_tag('a', with:{href: 'unan/home'}, text: 'UN FILM/ROMAN EN UN AN')
    end
    expect(page).to have_tag('a', with: {href: 'unan/paiement'}, text: 'S’inscrire au programme')
    # Note : l'inscription au programme fait l'objet d'un autre test
  end
  scenario '=> peut rejoindre l’abonnement au site' do
    try_signup_with_data( data_new_user )
    expect(page).to have_tag('a', with: {id: 'link_to_abonnement'}, text: 'vous abonner pour un an')
    click_link 'vous abonner pour un an'
    success "  trouve un bouton pour rejoindre l'abonnement."
    expect(page).to have_tag('h1', text: 'Section de paiement')
    expect(page).to have_tag('form', with: {id:'form_paiement'})
    success "  rejoint le formulaire de paiement de l'abonnement au site."
    # Note : le test de l'abonnement par ce biais sera testéa ailleurs
  end
  scenario 'peut confirmer son adresse mail' do
    truncate_table_users
    data_user = try_signup_with_data( data_new_user )
    # On récupère les données de l'user
    # On récupère le ticket
    hticket = db_get_ticket_with({user_id: 51, code: "User::get(51).confirm_mail"})

  end
end

feature "Un visiteur inscrit qui n'a pas encore validé son mail" do
  scenario "peut valider son mail à l'aide du lien dans son message" do
    pending
  end
end
