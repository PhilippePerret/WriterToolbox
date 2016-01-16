# encoding: UTF-8
=begin
Module qui doit être appelé toutes les heures par le cron-job.

NOTE : Il doit être exécutable.

=end

THIS_FOLDER = File.dirname(__FILE__)

def log mess
  reflog.puts "#{mess}"
end
def reflog
  @reflog ||= begin
    ref = File.open(reflog_path, 'a')
    ref.write( "\n\n" + ("-"*70) )
    now_humain = Time.now.strftime("%d %m %Y - %H:%M")
    ref.write( ("="*10) + "CRON JOB DU #{now_humain}" + ("="*10) + "\n\n" )
    ref
  end
end
def reflog_path
  @reflog_path ||= File.join(THIS_FOLDER, "log-#{Time.now.to_i}.log")
end

begin
  require File.join(THIS_FOLDER, 'lib', 'required.rb')
rescue Exception => e
  log "### IMPOSSIBLE DE CHARGER LES LIBRAIRIES : #{e.message}"
  log "### JE DOIS RENONCER À LANCER LE CRON-JOB"
  exit(1)
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
    begin
      log "### IMPOSSIBLE DE TRAITER LES AUTEURS DE UN AN UN SCRIPT EN ACTIVITÉ : #{e.message}\n"
      log e.backtrace.join("\n")
    rescue Exception => e
      File.open("./CRON/fatal_error.log", 'wb'){|f| f.write "#{e.message}\n\n" + e.backtrace.join("\n")}
    end
  end

end
