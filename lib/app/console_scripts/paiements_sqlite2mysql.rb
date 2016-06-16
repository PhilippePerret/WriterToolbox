# encoding: UTF-8
=begin

  Script autonome pour passer la table users.paiements de la base SQLite à
  la base MySQL.

  Le lancer par le biais de la console en online à l'aide de :
  run <nom du script>

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

  def debug foo
    (sub_log foo ) rescue nil
  end

end



begin

  Dir.chdir(OFFLINE ? "/Users/philippeperret/Sites/WriterToolbox": '.') do

    # La base SQLite
    dbpath = './database/data/users.db'
    dblite = SQLite3::Database.new(dbpath)
    # La table dans la base MySQL
    dbm_table = SiteHtml::DBM_TABLE.get(:cold, 'paiements')

    # RÉCUPÉRATION DES DONNÉES ORIGINALES
    # -----------------------------------
    pr = dblite.prepare('SELECT * FROM paiements')
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
      hdata[:montant] =
        case hdata[:montant]
        when 7  then 6.80
        when 13 then 12.90
        else hdata[:montant].to_f
        end
      dbm_table.insert( hdata )
    end
    debug "Nombre de rangées dans la table MySQL APRÈS l'opération : #{dbm_table.count}"

    # CRÉATION DU FICHIER D'IMPORT
    # ----------------------------
    code = original_data.collect do |hdata|
      hdata.values.join(";")
    end

  end #/chdir

rescue Exception => e
  debug "### ERREUR : #{e.message}"
  debug e.backtrace.join("\n")
ensure
  pr.close rescue nil
  dblite.close rescue nil
end
