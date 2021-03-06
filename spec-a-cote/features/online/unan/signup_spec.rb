=begin

  Test d'une inscription complète au programme UN AN UN SCRIPT
  - par un visiteur non inscrit et non abonné
  - par un visiteur inscrit mais non abonné
  - par un visiteur inscrit et abonné
=end
feature "Test d'une inscription au programme UN AN UN SCRIPT" do
  scenario "Un simple visiteur non inscrit" do
    now = Time.now.to_i
    duser = {
      pseudo: "InscriteUNAN", # pas de chiffres !
      patronyme: "Inscrite UnanunScript",
      mail: "boa.inscrite.unan@gmail.com",
      password: "#{now}"
    }
    start_time = Time.now.to_i
    table_users_online = site.dbm_table(:hot, 'users', online = true)

    # On détruit cet user s'il existe
    table_users_online.delete(where: "mail = '#{duser[:mail]}'")


    visit site.distant_url
    expect(page).to have_link('OUTILS')
    click_link('OUTILS')
    expect(page).to have_link('Le programme “Un An Un Script”')
    click_link('Le programme “Un An Un Script”', match: :first)
    expect(page).to have_css('h1', text: 'Le Programme “Un An Un Script”')
    expect(page).to have_link('S’inscrire au programme')
    click_link('S’inscrire au programme')
    # On se retrouve sur la page d'inscription au programme
    expect(page).to have_css('form#form_user_signup')
    # On remplit le formulaire
    within('form#form_user_signup') do
      fill_in('user_pseudo', with: duser[:pseudo])
      fill_in('user_patronyme', with: duser[:patronyme])
      fill_in('user_mail', with: duser[:mail])
      fill_in('user_mail_confirmation', with: duser[:mail])
      fill_in('user_password', with: duser[:password])
      fill_in('user_password_confirmation', with: duser[:password])
      fill_in('user_captcha', with: '366')
      click_button("S'inscrire")
    end
    expect(page).not_to have_css('#flash div.error')
    expect(page).to have_css('form#form_paiement')
    # Il faut récupérer le contenu du champ hidden name='token'
    within('form#form_paiement') do
      token = find('input[name="token"]').inner_html
      puts "token = #{token}"
    end

  end
end
