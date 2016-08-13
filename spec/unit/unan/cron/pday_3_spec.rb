require_relative '_required'



describe 'Pour un 3e jour d’un auteur du programme UNAN' do

  before(:all) do
    remove_all_programs_unan
    benoit.set_auteur_unanunscript(
      pday:     3,
      verbose:  true
    )
  end


  it 'Le cron fait changer le jour-programme de benoit (sans travaux non démarrés)' do

    test 'Le cron fait passer Benoit au 3e jour-programme'

    start_time = NOW - 1

    # On détruit le fichier erreur s'il existe
    patherror = File.join('./CRON2/log_error.log')
    File.unlink patherror if File.exist? patherror

    ben = User.new(2)

    # Il faut préparer Benoit
    ben.program.set(
      current_pday: 2,
      current_pday_start: NOW - 1.day - 3.hours
      )

    ben.demarre_ses_travaux :all

    # Premières vérifications
    expect(ben.program.current_pday).to eq 2

    # === EXÉCUTION ===
    require './CRON2/lib/required/mod_methodes_procedure.rb'
    require './CRON2/lib/procedure/un_an_un_script/duser_extension'
    require './CRON2/lib/procedure/un_an_un_script/un_an_un_script'
    CRON2.instance.un_an_un_script

    # === VÉRIFICATION ===

    # Il ne doit pas y avoir eu d'erreur
    le_fichier(patherror).nexistepas(success: 'Aucune erreur n’a été rencontrée.')

    ben = User.new(2)
    # Pour le moment, on doit reprendre vraiment le programme,
    # sinon les valeurs ne sont pas changées
    programme = Unan::Program.new(ben.program.id)
    expect(programme.current_pday).to eq 3
    success "Benoit est passé au 2e jour-courant."

    benoit.a_recu_le_mail(
      sent_after: start_time,
      subject:    "Rapport journalier du #{NOW.as_human_date(true, false, ' ')}",
      success:    "Benoit a reçu le mail journalier"
    )
    imail = MailMatcher.mails_found.first
    message = imail.message_content #.strip_tags
    # puts "MESSAGE : #{message}"

    le_texte(message).
      contient('Veuillez trouver ci-dessous le rapport de votre travail sur le programme', success: 'Le mail contient la bonne invite.').
      et(NOM_PROGRAMME_UNAN, success: 'La mail contient le titre du programme.').
      contient_la_balise('span', text: '0', id: 'nombre_points', class: 'points fright', success: 'Benoit n’a pas de points.').
      et('span', id: 'jour_reel', text: '2', success: 'On indique à Benoit qu’il est à son 2e jour réel.').
      et('span', id: 'jour_programme', text: '2', success: 'On indique à Benoit qu’il est à son 2e jour-programme.').
      et('span', text: 'Notez, Benoite, que vous avez 1 alerte mineure.').
      et('fieldset', id: 'fs_works_unstarted', success: 'Le mail contient le fieldset des travaux non démarrés.').
      et('fieldset', id: 'fs_new_works', success: 'Le mail contient le fieldset des nouveaux travaux.').
      et('fieldset', id: 'fs_liens_utiles')

    le_texte(message).
      contient_la_balise('legend', text: 'Travaux à démarrer (1)', in: 'fieldset#fs_works_unstarted').
      et('legend', text: 'Nouveaux travaux (4)', in: 'fieldset#fs_new_works').
      et('legend', text: 'Liens utiles', in: 'fieldset#fs_liens_utiles')

  end


end
