# encoding: UTF-8
=begin
Module qui doit être appelé toutes les heures par le cron-job.

NOTE : Il doit être exécutable (? je pense que oui).

=end

THIS_FOLDER = File.dirname(__FILE__)
require File.join(THIS_FOLDER, 'lib', 'required.rb')

def log mess
  reflog.puts "#{mess}"
end
def reflog
  @reflog ||= begin
    ref = File.open(reflog_path, 'a')
    ref.write "\n\n" + ("-"*70)
    now_humain = Time.now.strftime("%d %m %Y - %H:%M")
    ref.write ("="*10) + "CRON JOB DU #{now_humain}" + ("="*10) + "\n\n"
  end
end
def reflog_path
  @reflog_path ||= File.join(THIS_FOLDER, "log.log")
end

# On se place à la racine de l'application pour
# exécuter toutes les opérations
Dir.chdir("#{APP_FOLDER}") do
  # On requiert tout ce qu'il faut requérir
  require "./lib/required"

  # Toutes les heures, voir si des auteurs en activité
  # sur le programme UN AN UN SCRIPT doivent être passés
  # au jour-programme suivant.
  begin
    User::traite_users_unanunscript
  rescue Exception => e
    log "### IMPOSSIBLE DE TRAITER LES AUTEURS DE UN AN UN SCRIPT EN ACTIVITÉ : #{e.message}\n"
    log e.backtrace.join("\n")
  end

end
