# encoding: UTF-8
=begin

  Script autonome pour passer la table site_hot.todolist de la base SQLite à
  la base MySQL.

  Le lancer dans TextMate

=end
require 'json'

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

    # La base SQLite
    dbpath = './database/data/cnarration.db'
    dblite = SQLite3::Database.new(dbpath)
    # La table dans la base MySQL
    dbm_table = SiteHtml::DBM_TABLE.new(:cnarration, 'tdms')

    # RÉCUPÉRATION DES DONNÉES ORIGINALES
    # -----------------------------------
    pr = dblite.prepare('SELECT * FROM tdms')
    original_data = []
    pr.execute.each_hash do |row|
      original_data << row.to_sym
    end

    # CRÉATION DES DONNÉES DANS LA NOUVELLE BASE LOCALE
    # -------------------------------------------------
    dbm_table.destroy if dbm_table.exists?
    dbm_table.create_if_needed
    debug "Nombre de rangées dans la table mySQL AVANT l'opération : #{dbm_table.count}"
    original_data.each do |hdata|
      # ---------------------------------------------------------------------
      # TRANSFORMATION OPTIONNELLE DES DONNÉES
      # ---------------------------------------------------------------------
      hdata.each do |k, v|
        hdata[k] = nil if v == 'NULL'
      end
      hdata[:tdm] = JSON.parse(hdata[:tdm]).join(',')
      # ---------------------------------------------------------------------
      # /FIN TRANSFORMATION DES DONNÉES
      # ---------------------------------------------------------------------
      dbm_table.insert( hdata )
    end
    debug "Nombre de rangées dans la table MySQL APRÈS l'opération : #{dbm_table.count}"

  end #/chdir

rescue Exception => e
  debug "### ERREUR : #{e.message}"
  debug e.backtrace.join("\n")
ensure
  pr.close rescue nil
  dblite.close rescue nil
end
