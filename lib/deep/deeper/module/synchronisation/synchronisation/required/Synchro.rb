# encoding: UTF-8
#
# On charge les données de synchronisation propres
# au site, à commencer par :
#   - les informations SSH
#   - les dossiers à traiter
#   - les fichiers/dossiers à ignorer
#
require './objet/site/data_synchro'

# Extension de Synchro
class Synchro

  #
  # Donnée contenant le resultat final
  #
  # Ses clés sont les paths des fichiers. Les valeurs sont des Hash
  # définissant :date_serveur (date du fichier online ou NIL si le fichier
  # n'existe pas) :date_local (date du fichier offline ou NIL si le fichier
  # n'existe pas).
  #
  attr_reader :result

  ##
  #
  # = main =
  #
  # Méthode principale qui check la synchro entre les deux sites
  # pour peupler @result
  #
  # Note: Cette méthode doit être appelée offline
  #
  def check_synchro


    #
    # Relève les fichiers et dates sur le site local
    #
    check_folders_offline

    #
    # Relève les fichiers et les dates sur le site distant
    #
    check_folders_online

    #
    # Construire le résultat
    #
    build_result

    #
    # L'ouvrir dans le navigateur
    #
    open_result

  end

  def check_folders_online
    # Appeler ce script et le jouer sur le serveur
    # res = `ssh serveur_icare "ruby run_online.rb './ruby/module/check/synchronisation.rb'" -q`
    fullpath_folder = File.dirname(folder)
    fullpath_racine = File.expand_path('.')
    folder_upto_synchro = fullpath_folder.sub(/^#{fullpath_racine}\//, './')
    res = `ssh #{serveur_ssh} "ruby run_online.rb '#{folder_upto_synchro}/synchronisation.rb'" -q`
    begin
      res = Marshal.load(res)
      res.each do |file_path, file_data|
        if @result.has_key? file_path
          @result[file_path][:tdis] = file_data[:tdis]
        else
          @result.merge! file_path => file_data
        end
      end
    rescue Exception => e
      puts "Une erreur est malheureusement survenue : #{e.message}"
      puts "(consulter le fichier `#{path_log}` pour le détail)"
      puts e.backtrace.join("\n")
      debug "RETOUR SSH (évalué par Marshal) : #{res.inspect}::#{res.class}"
    end
  end

  def check_folders_offline
    check_folders
  end

  ##
  #
  # Construction du fichier HTML des résultats
  #
  def build_result
    output.build_html_file
  end


  def open_result
    # `open -a Firefox "#{path_html_file}"`
    # Pour bénéficier d'ajax
    app_path = File.expand_path(".")
    sync_path = File.expand_path(folder.to_s)
    rel_path = sync_path.sub(/^#{app_path}\//,'')
    fin_path = "http://localhost/#{app_name}/#{rel_path}/output/#{name_html_file}"
    # `open http://localhost/AlwaysData/Icare_AD/ruby/module/check/synchronisation/output/#{name_html_file}`
    `open #{fin_path}`
  end

  ##
  #
  # Relève tous les fichiers avec leurs dates
  #
  def check_folders
    @result = {}
    folders_2_check.each do |folder, dfolder|
      files_of_folder(folder).each { |path| traite_file path, dfolder }
    end
  end

  ##
  #
  # @RETURN les fichiers du dossiers +folder+ (en cherchant aussi dans les
  # sous-dossier)
  #
  def files_of_folder folder
    extensions = folders_2_check[folder][:extensions]
    les_fichiers = []
    les_fichiers += Dir.glob("#{File.join('.', folder)}/*.{#{extensions.join(',')}}")
    Dir["./#{folder}/**/**"].each do |subfolder|
      next unless File.directory? subfolder
      next if ignored_files.has_key? "#{subfolder}/"
      next if ignored_subfolder? subfolder
      les_fichiers += Dir.glob("#{subfolder}/*.{#{extensions.join(',')}}")
    end
    return les_fichiers
  end

  def ignored_subfolder? subfolder
    ignored_folders.each do |ignored_folder|
      return true if subfolder.start_with? ignored_folder
    end
    return false
  end

  def ignored_folders
    @ignored_folders ||= begin
      arr = Array::new # vide pour le moment
      arr += app_ignored_folders
      arr
    end
  end
  def ignored_files
    @ignored_files ||= begin
      @ignored_folders = []
      h = {}
      # Ajouter quelques fichiers obligatoirement ignorés
      h.merge!(
      "./lib/deep/deeper/module/synchronisation/synchronisation/output/ajax.rb" => true
      )
      app_ignored_files.each do |p|
        p = p.strip
        if File.directory? p
          @ignored_folders << p
        else
          h.merge! p => true
        end
      end
      h
    end
  end

  ##
  #
  # Méthode qui enregistre un fichier et sa date
  #
  #
  def traite_file path, dfolder
    return if ignored_files[path] == true
    unless @result.has_key? path
      @result.merge! path => { tdis: nil, tloc: nil, dir: dfolder[:dir] }
    end
    key = MODE_SERVEUR ? :tdis : :tloc
    @result[path][key] = File.stat(path).mtime.to_i
  end

  ##
  #
  # @RETURN une instance Synchro::Output pour la construction du
  # fichier HTML
  #
  def output
    @output ||= Synchro::Output::new(self)
  end

  ##
  #
  # Path au fichier HTML
  #
  def path_html_file
    @path_html_file ||= File.join(folder, 'output', name_html_file)
  end
  ##
  #
  # Nom du fichier HTML
  #
  def name_html_file
    @name_html_file ||= "check_synchro_#{Time.now.strftime('%Y-%m-%d-%H-%M')}.html"
  end

  def folder
    @folder ||= FOLDER_SYNCHRONISATION
  end
end
