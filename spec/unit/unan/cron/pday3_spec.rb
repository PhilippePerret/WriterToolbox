=begin

  Test du deuxième jour de Benoit

=end
def log str, opts = nil
  puts str
end
def superlog str
  puts "Superlog: #{str}"
end
class CRON2
  class Histo
    def self.add h; end
  end
end

describe 'Deuxième jour du programme UN AN' do
  before(:all) do
    remove_all_programs_unan
    benoit.set_auteur_unanunscript(
      pday:     2,
      verbose:  true
    )
  end
  it 'Le cron fait changer le jour-programme de benoit' do
    test 'Le cron fait changer le jour-programme de benoit'

    start_time = NOW - 1

    # On détruit le fichier erreur s'il existe
    patherror = File.join('./CRON2/log_error.log')
    File.unlink patherror if File.exist? patherror

    ben = User.new(2)

    # Il faut préparer Benoit
    ben.program.set(
      current_pday: 1,
      current_pday_start: NOW - 1.day - 3.hours
      )
    expect(ben.program.current_pday).to eq 1

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
    expect(programme.current_pday).to eq 2
    success "Benoit est passé au 2e jour-courant"

    puts "On va vérifier tout le mail envoyé"
    benoit.a_recu_le_mail(
      sent_after: start_time,
      subject:    "Rapport journalier du #{NOW.as_human_date(true, false, ' ')}",
      success:    "Benoit a reçu le mail journalier"
    )
    imail = MailMatcher.mails_found.first
    message = imail.message_content.strip_tags
    puts "Message : #{message}"

    le_texte(message).contient('Veuillez trouver ci-dessous le rapport de votre travail sur le programme').
      et(NOM_PROGRAMME_UNAN)

    pending "À poursuivre"

  end
end
