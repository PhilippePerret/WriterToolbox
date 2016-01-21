# encoding: UTF-8
=begin

Fichier principal appelé par `hour_cron.rb` à la racine (plus justement,
appelé par ./lib/required.rb en premier).

=end
class Cron
  def self.run
    # On se place à la racine de l'application pour
    # exécuter toutes les opérations
    Dir.chdir("#{APP_FOLDER}") do
      # On requiert tout ce qu'il faut requérir
      begin
        require "./lib/required"
      rescue Exception => e
        log "### IMPOSSIBLE DE CHARGER LES LIBRAIRIES DU SITE : #{e.message}"
        lob "### JE DOIS RENONCER"
        exit(1)
      end

      # L'objet Unan doit être requis pour traiter tout ce qui
      # concerne le programme UN AN UN SCRIPT
      begin
        site.require_objet 'unan'
      rescue Exception => e
        log "### IMPOSSIBLE DE REQUÉRIR L'OBJET `unan` : #{e.message}"
        log "### JE DOIS RENONCER"
        exit(1)
      end

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
  end #/run
end
