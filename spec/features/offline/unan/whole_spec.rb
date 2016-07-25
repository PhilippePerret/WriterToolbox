=begin

  Test d'une inscription complète au programme UN AN UN SCRIPT
  - par un visiteur non inscrit et non abonné
  - par un visiteur inscrit mais non abonné
  - par un visiteur inscrit et abonné
=end
DUSER = TUnan::DUSER
def inscrite
  TUnan.inscrite
end

feature "Test d'une inscription au programme UN AN UN SCRIPT (OFFLINE)" do


  scenario "Un simple visiteur non inscrit" do

    # Pour faire des petites pauses pour avoir le temps
    # de voir les pages
    @pause_on = false

    now = Time.now.to_i
    start_time = Time.now.to_i - 1
    table_users_offline = site.dbm_table(:hot, 'users', online = false)

    # On efface l'user s'il a été créé
    #   - dans la table des users
    #   - Dans la table :unan des programmes
    #   - dans la table :unan des projets
    oldu = table_users_offline.get(where: "mail = '#{DUSER[:mail]}' OR pseudo = '#{DUSER[:pseudo]}'")
    puts "oldu existe ? #{oldu.nil? ? 'NON' : 'OUI'}"
    unless oldu.nil?
      oldu_id = oldu[:id]
      table_users_offline.delete(oldu_id)
      site.dbm_table(:unan, 'programs').delete(where: "auteur_id = #{oldu_id}")
      site.dbm_table(:unan, 'projets').delete(where: "auteur_id = #{oldu_id}")
      if User.table_paiements.count(where: "user_id = #{oldu_id}") > 0
        User.table_paiements.delete(where: "user_id = #{oldu_id}")
        puts "Suppression du paiement précédent."
      end
      ['variables', 'unan_works', 'unan_quiz', 'unan_pages_cours'
      ].each do |key|
        tbl_name = "#{key}_#{oldu_id}"
        tbl = SiteHtml::DBM_TABLE.new(:users_tables, tbl_name)
        if tbl.exists?
          tbl.destroy
          puts "La table #{tbl_name} existait. Je l'ai détruite."
        end
      end
    end

    # ON REJOINT LE SITE LOCAL
    visit_home

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
      fill_in('user_pseudo', with: DUSER[:pseudo])
      fill_in('user_patronyme', with: DUSER[:patronyme])
      fill_in('user_mail', with: DUSER[:mail])
      fill_in('user_mail_confirmation', with: DUSER[:mail])
      fill_in('user_password', with: DUSER[:password])
      fill_in('user_password_confirmation', with: DUSER[:password])
      fill_in('user_captcha', with: '366')
      click_button("S'inscrire")
    end

    sleep 3 if @pause_on

    expect(page).not_to have_css('#flash div.error')
    # On détruit ce compte
    expect(page).to have_css('form#form_paiement')
    # Il faut récupérer le contenu du champ hidden name='token'
    token =
      within('form#form_paiement') do
        find('input[type="hidden"][name="token"]', visible: false).value
      end

    # On récupère les données de l'user dans la base de
    # données, on peut les vérifier en même temps
    huser = table_users_offline.get(where: "mail = '#{DUSER[:mail]}'")
    DUSER.merge! id: huser[:id]
    puts "ID user : #{DUSER[:id]}"

    # Pour le moment, on simule le paiement paypal en se rendant
    # directement à l'adresse.
    # Mais avant, il faut créer un enregistrement du paiement pour
    # que ça fonctionne
    now = Time.now.to_i
    User.table_paiements.insert(
      user_id:    DUSER[:id],
      objet_id:   '1AN1SCRIPT',
      montant:    19.8,
      facture:    token,
      created_at: now
    )
    data_autorisation = {
      user_id: DUSER[:id],
      raison: "1AN1SCRIPT",
      start_time: now - 3600,
      end_time:   (now - 3600) + (2 * 365.days),
      created_at: now - 3600,
      updated_at: now - 3600,
      nombre_jours: (2 * 365)
    }
    User.table_autorisations.insert(data_autorisation)
    
    visit "#{site.local_url}/paiement/on_ok?in=unan"

    # Ça doit construire UN PROGRAMME valide pour l'user
    hprogram = site.dbm_table(:unan, 'programs').select(where: "created_at > #{start_time}").first
    expect(hprogram).not_to eq nil
    expect(hprogram).to be_instance_of Hash
    expect(hprogram[:auteur_id]).to eq DUSER[:id]
    expect(hprogram[:current_pday]).to eq 1
    expect(hprogram[:points]).to eq 0
    expect(hprogram[:rythme]).to eq 5
    expect(hprogram[:created_at]).to be > start_time
    # Ça doit construire UN PROJET valide pour l'user
    hprojet = site.dbm_table(:unan, 'projets').get(where: "program_id = #{hprogram[:id]}")
    # L'ID du projet dans les données du programme sont valides
    expect(hprogram[:projet_id]).to eq hprogram[:id]
    expect(hprojet).not_to eq nil
    expect(hprojet[:auteur_id]).to eq DUSER[:id]
    expect(hprojet[:program_id]).to eq hprogram[:id]
    expect(hprojet[:titre]).to eq nil
    expect(hprojet[:resume]).to eq nil
    expect(hprojet[:specs]).to eq '000'
    expect(hprojet[:created_at]).to be > start_time

    # Envoi des mails (pas en online)
    expect(phil).to have_mail_with(
      sent_after: start_time,
      subject:    "Nouvelle inscription (##{DUSER[:id]})"
    )
    expect(inscrite).to have_mail_with(
      sent_after: start_time,
      subject:    'Premières explications'
    )
    expect(inscrite).to have_mail_with(
      sent_after: start_time,
      subject:    'Confirmation inscription'
    )
    expect(inscrite).to have_mail_with(
      sent_after: start_time,
      subject: 'Merci de confirmer votre mail'
    )

    # ---------------------------------------------------------------------
    # LA PAGE DE LANCEMENT
    # ---------------------------------------------------------------------

    sleep 3 if @pause_on
    expect(page).to have_css('h2', text: "C'est parti !")
    expect(page).to have_content("Le Programme “Un An Un Script”")

    # ---------------------------------------------------------------------
    # Elle clique le lien pour régler les propriétés du programme
    # Elle rejoint son bureau de travail, le panneau préférences.
    # ---------------------------------------------------------------------
    titre_link_regler = 'régler ensemble les propriétés du programme'
    expect(page).to have_link(titre_link_regler)
    click_link(titre_link_regler)

    sleep 3 if @pause_on

    expect(page).to have_content("Le Programme “Un An Un Script”")
    expect(page).to have_css('h2', text: 'Votre centre de travail')
    expect(page).to have_css('h3', text: 'Préférences')

    # ONGLET ÉTAT
    expect(page).to have_link('État')
    click_link('État')
    sleep 3 if @pause_on
    expect(page).not_to have_css('h3', text: 'Préférences')
    expect(page).to have_css('h3', text: 'État général du programme')
    # Il doit être au premier jour et ne pas avoir de points
    within('div#div_mark_pday_points') do
      expect(page).to have_css('span', text: '1er')
      expect(page).to have_css('span#mark_points', text: '0')
    end

    # ONGLET PRÉFÉRENCES
    # ---------------------------------------------------------------------
    # on retourne à l'onglet préférences pour faire cette expérience :
    # À ce niveau du programme, l'auteur ne doit pas avoir de table
    # variables encore. Mais quand on règle les préférences, elle
    # peut en avoir une.

    # La table des variables
    # Noter qu'elle existe déjà.
    table_variables = SiteHtml::DBM_TABLE.new(:users_tables, "variables_#{DUSER[:id]}")
    expect(table_variables).to be_exists
    pref = table_variables.get(where: 'name = "pref_daily_summary"')
    expect(pref).to be nil

    expect(page).to have_link('Préférences')
    click_link('Préférences')
    sleep 3 if @pause_on
    expect(page).to have_css('h3', text: 'Préférences')

    # On va modifier la préférence d'envoi des comptes rendus pour
    # voir si ça les enregistre
    within('form#preferences') do
      expect(page).to have_css('input#pref_daily_summary')
      uncheck('pref_daily_summary')
      click_button('Enregistrer', match: :first)
    end

    sleep 3 if @pause_on

    expect(page).to have_css("div.notice", text: "Préférences enregistrées.")

    hpref = table_variables.get(where: 'name = "pref_daily_summary"')
    expect(hpref[:value]).to eq '0'

    # Elle recoche sa case pour recevoir un rapport
    # journalier.
    within('form#preferences') do
      expect(page).to have_css('input#pref_daily_summary')
      check('pref_daily_summary')
      click_button('Enregistrer', match: :first)
    end
    hpref = table_variables.get(where: 'name = "pref_daily_summary"')
    expect(hpref[:value]).to eq '1'

    expect(page).to have_link('Déconnexion')
    click_link('Déconnexion')
    expect(page).to have_content("À très bientôt, #{DUSER[:pseudo]}")
  end

  scenario 'Inscrite doit confirmer son adresse mail à la prochaine connection.' do

    site.require_module 'ticket'

    start_time = Time.now.to_i - 1
    table_users_offline = site.dbm_table(:hot, 'users', online = false)
    hinscrite = table_users_offline.get(where: "mail = '#{DUSER[:mail]}'")
    # Une instance User

    go_and_identify DUSER[:mail], DUSER[:password]
    shot('apres-identification')

    expect(page).to have_css('div.error', text: "Désolé #{DUSER[:pseudo]}, mais vous ne pouvez pas vous reconnecter avant d’avoir confirmé votre adresse-mail.")


    # Elle confirme son inscription en cliquant sur le lien du mail.
    hticket = app.table_tickets.get(where: "user_id = #{DUSER[:id]}")
    puts hticket.inspect
    link_confirmation = "#{site.local_url}?tckid=#{hticket[:id]}"

    visit link_confirmation

    shot('after-confirm-mail')

    sleep 3 if @pause_on

    expect(page).to have_css('div.notice', text: "Merci à vous #{DUSER[:pseudo]}, votre mail et votre inscription sont confirmés.")

  end

end
