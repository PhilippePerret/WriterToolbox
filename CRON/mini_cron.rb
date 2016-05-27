# encoding: UTF-8
=begin

  Petit module isolé pour vérifier simplement que le site online
  fonctionne correctement sur les pages minimales.

=end


def safed_log mess
  File.open(safed_log_path, 'a') do |f|
    f.write "#{mess}\n"
  end rescue nil
end
def safed_log_path
  @safed_log_path ||= "#{RACINE}/CRON/mini_cron.log"
end

# Donc le dossier CRON
THIS_FOLDER = File.expand_path(File.dirname(__FILE__))
# Donc le dossier de l'application, qu'on soit online ou offline
RACINE      = File.expand_path(File.join(THIS_FOLDER, '..'))
ONLINE      = RACINE.split('/').last == "WriterToolbox"
OFFLINE     = !ONLINE

# Requérir la classe MiniMail qui permettra d'envoyer
# le mail.
require "#{THIS_FOLDER}/lib/required/mini_mail"

# ---------------------------------------------------------------------
#   DÉBUT DES OPÉRATIONS
# ---------------------------------------------------------------------
begin
  # Destruction du fichier log
  File.unlink(safed_log_path) if File.exist?(safed_log_path)

  safed_log "=== DÉBUT du mini_cron.rb : #{Time.now} ==="

  suivi = ['**Vérification des pages minimales**']

  error_encountered = false
  success_pages = []
  failure_pages = []

  [
    ['', 'Page d’accueil'],
    # Ajouter la route ci-dessous pour provoquer volontairement
    # une erreur (pour tester le test par exemple)
    # ['bad/for/test', 'Mauvaise route pour voir'],
    ['user/signin', 'Formulaire d’identification'],
    ['user/signup', 'Formulaire d’inscription'],
    ['tool/list', 'Liste des outils'],
    ['unan/home', 'Programme UN AN UN SCRIPT'],
    ['analyse/home', 'Page d’accueil des analyses'],
    ['calculateur/main', 'Calculateur de structure'],
    ['video/home', 'Tutoriels vidéos'],
    ['cnarration/home', 'Collection Narration'],
    ['livre/list?in=cnarration', 'Liste des livres de Narration'],
    ['facture/main', 'Producteur de facture'],
    ['forum/home', 'Accueil du Forum'],
    ['scenodico/home', 'Accueil du Scénodico'],
    ['filmodico/home', 'Accueil du Filmodico']
  ].each do |droute|
    route, name = droute
    begin
      url = "http://www.laboiteaoutilsdelauteur.fr/#{route}"
      # Note : Ne pas mettre 2>&1 à la fin sinon les premières
      # lignes seront la progresse barre
      res = `curl -I #{url}`
      first_line = res.split("\n").first
      ok = first_line.include?('200') && first_line.include?('OK')
      if ok
        success_pages << droute
      else
        failure_pages << (droute << first_line)
      end
    rescue Exception => e
      suivi << "Problème avec la page #{route} (#{name}) : #{e.message}"
    end
  end

  suivi << 'Fin de la vérification des pages minimales.'

rescue Exception => e
  safed_log "# ERREUR : #{e.message}"
ensure
  safed_log "\n\n === FIN DU mini_cron.rb : #{Time.now} ==="
end

# Envoi du message de suivi à l'administration
# ---------------------------------------------
# Note : pour le moment, je l'envoie chaque fois, mais ensuite il ne
# faudra l'envoyer que lorsqu'une erreur se sera produite.
begin
  if failure_pages.count > 0
    rapport = ""
    rapport << "\n=== GRAVE PROBLÈME DÉTECTÉ SUR LE SITE BOA ===\n"
    rapport << "\n### Des pages n'ont pas pu être atteintes au cours du mini-cron test : ###\n\n"
    rapport <<
      failure_pages.collect do |dpage|
        route, name, statut = dpage
        "# ECHEC POUR : #{name} (#{route}).\n  STATUT : #{statut}"
      end.join("\n")
    rapport << "\n\n*** Pages ayant pu être atteintes : ***\n\n"
    rapport <<
      success_pages.collect do |droute|
        route, name = droute
        "- #{name} (#{route})"
      end.join("\n")

    # === ENVOI DU MESSAGE ===
    MiniMail.new().send( rapport, "MAIL D’ALERTE du mini-cron - #{Time.now}" )

  end
rescue Exception => e
  MiniMail.new().send( "PROBLÈME : #{e.message}\n" +  e.backtrace.join("\n"))
else
  File.unlink(safed_log_path) if File.exist?(safed_log_path)
end
# ---------------------------------------------------------------------
#   FIN DES OPÉRATIONS
# ---------------------------------------------------------------------
