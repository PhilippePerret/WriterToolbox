# encoding: UTF-8
=begin

  Script autonome pour passer toutes les tables des variables
  d'user dans la base `boite-a-outils_users_tables`.

  Noter que le traitement est un peu différent des tables
  habituelles dans le sens où le nom est fabriqué à partir
  de l'identifiant de l'auteur.
  D'autre part, les tables se trouvent dans le dossier
  ./database/data/user/

=end
unless defined?(OFFLINE)
  require 'sqlite3'
  require 'mysql2'
  OFFLINE = true
  ONLINE  = !OFFLINE
end

if OFFLINE
  # Si on est en offline, il faut importer certaines librairies utiles
  require '/Users/philippeperret/Sites/WriterToolbox/lib/deep/deeper/required/extensions/hash.rb'
  Dir['/Users/philippeperret/Sites/WriterToolbox/lib/deep/deeper/required/Site/mysql/**/*.rb'].each{|m| require m}
end

def debug foo
  (console.sub_log "#{foo}<br>") rescue nil
end


begin

  Dir.chdir(OFFLINE ? "/Users/philippeperret/Sites/WriterToolbox": '.') do

    # Il faut boucler sur toutes les bases users
    Dir["./database/data/unan/user/*"].each do |ufolder|
      uid = File.basename(ufolder).to_i
      debug "User ##{uid}"
      dbpath = Dir["#{ufolder}/*.db"].first
      next if dbpath.nil?
      debug "   - dbpath: #{dbpath}"
      dblite = SQLite3::Database.new(dbpath)
      # La table dans la base MySQL
      table_name = "unan_pages_cours_#{uid}"
      dbm_table = site.dbm_table(:users_tables, table_name)
      dbm_table.destroy if dbm_table.exist?
      dbm_table.create
      # dbm_table = SiteHtml::DBM_TABLE.get(:users_tables, table_name)

      # RÉCUPÉRATION DES DONNÉES ORIGINALES
      # -----------------------------------
      begin
        pr = dblite.prepare('SELECT * FROM pages_cours')
      rescue Exception => e
        # Pas de table variables pour ce user
        debug "# Pas de pages de cours => je passe au suivant"
        next
      end
      original_data = []
      pr.execute.each_hash do |row|
        original_data << row.to_sym
      end

      next if original_data.empty?

      # CRÉATION DES DONNÉES DANS LA NOUVELLE BASE LOCALE
      # -------------------------------------------------
      original_data.each do |hdata|
        # ---------------------------------------------------------------------
        # TRANSFORMATION OPTIONNELLE DES DONNÉES
        # ---------------------------------------------------------------------
        hdata.each do |k, v|
          # Il faut toujours faire ça
          hdata[k] = nil if v == 'NULL'
        end
        # ---------------------------------------------------------------------
        # /FIN TRANSFORMATION DES DONNÉES
        # ---------------------------------------------------------------------
        dbm_table.insert( hdata )
      end
      debug "Nombre de rangées dans la table MySQL APRÈS l'opération : #{dbm_table.count}"

    end # /Fin de boucle sur tous les users
  end #/chdir

rescue Exception => e
  debug "### ERREUR : #{e.message}"
  debug e.backtrace.join("\n")
ensure
  pr.close rescue nil
  dblite.close rescue nil
end
