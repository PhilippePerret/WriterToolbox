# encoding: UTF-8
=begin

  Module de synchronisation de la collection Narration.
  Cette synchronisation joue sur deux choses :
    - les données de la base `boite-a-outils_cnarration`
    - les fichiers physiques des livres

=end
class Sync

  def synchronize_narration
    @report << "* Synchronisation IMMÉDIATE de la Collection NARRATION"
    if Sync::CNarration.instance.synchronize(self)
      @report << "= Synchronisation de la collection Narration OPÉRÉE AVEC SUCCÈS"
    else
      @report << "# PROBLÈME AVEC LA SYNCHRONISATION DE LA COLLECTION NARRATION".in_span(class: 'red')
    end
  end

class CNarration
  include Singleton
  include CommonSyncMethods

  # = main =
  #
  # Méthode principale de la synchronisation de la collection Narration.
  # - au niveau de la base de données
  # - au niveau des fichiers à synchroniser
  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0

    # Syncrhonisation des données des pages et
    # chapitre/sous-chapitre de la collection
    synchronize_database

    # Synchronisation des données de tables des
    # matières de la collection narration
    nb_sync = Sync::TDMNarration.instance.synchronize(sync)
    @nombre_synchronisations += nb_sync

    # Synchronisation des fichiers physiques de la
    # collection.
    synchronize_fichiers

    report "NOMBRE SYNCHRONISATIONS : #{@nombre_synchronisations}"
  rescue Exception => e
    debug e
    self.error "# PROBLÈME SYNCHRO NARRATION : #{e.message}"
    false
  else
    true
  end

  def synchronize_database

    report "* Synchronisation des données de database"
    report "Nombre de rangées locales   : #{loc_rows.count}"
    report "Nombre de rangées distantes : #{dis_rows.count}"

    # Boucle sur chaque page locale
    # Note : Puisque les pages ne peuvent être que créées localement,
    # il est inutile de vérifier les pages distantes.
    loc_rows.each do |pid, loc_data|
      dis_data = dis_rows[pid]

      if loc_data != dis_data
        # Données différentes
        # Si c'est le niveau de développement qui a changé, il faut
        # updater le niveau le plus bas.
        # Si c'est une autre donnée qui a changé, il faut prendre
        # l'updated_at pour voir la plus récente (et signaler quand même
        # un problème si c'est en online que la modification est la plus
        # récente, ce qui ne devrait pas vraiment arriver)
        if loc_data[:options][1] != dis_data[:options][1]
          # NIVEAU DE DÉVELOPPEMENT DIFFÉRENT
          update_niveau_developpement(pid, loc_data, dis_data)
          @nombre_synchronisations += 1
        else
          # Autre donnée différente. Dans ce cas, on prend
          # la date de dernière modification pour savoir quelle
          # donnée doit être actualisée
          if loc_data[:udpated_at] > dis_data[:updated_at]
            # OK => actualisation de la donnée distante
            dis_table.update(pid, loc_data)
            @nombre_synchronisations += 1
          else
            # Actualisation de la donnée locale, mais attention,
            # c'est bizarre puisqu'on ne devrait pas modifier les
            # données en distant.
            loc_table.update(pid, dis_data)
            @nombre_synchronisations += 1
          end
        end
      else
        suivi "Pages ##{pid} loc/dis identifiques"
      end
    end
  end

  def synchronize_fichiers
    loc_files = get_fichiers_locaux
    dis_files = get_fichiers_distants
    report "* Synchronisation des fichiers physiques"
    report "Nombre fichiers locaux   : #{loc_files.count}"
    report "Nombre fichiers distants : #{dis_files.count}"

    loc_files.each do |loc_path, loc_mtime|
      dis_mtime = dis_files.delete(loc_path)

      if dis_mtime.nil? || loc_mtime > dis_mtime
        if dis_mtime.nil?
          suivi "Le fichier #{loc_path} n'existe pas en online."
          report "* Création du fichier DISTANT #{loc_path}…"
        elsif loc_mtime > dis_mtime
          suivi "Le fichier LOCAL #{loc_path} est plus jeune"
          report "* Actualisation du fichier DISTANT #{loc_path}…"
        end
        upload_narration_file(loc_path)
        report "= OK"
        @nombre_synchronisations += 1
      elsif dis_mtime > loc_mtime
        suivi "Bizarre, le fichier distant #{loc_path} est plus jeune que le fichier local (local: #{loc_mtime.inspect} / distant: #{dis_mtime.inspect})…"
      else
        suivi "Fichier #{loc_path} OK"
      end
    end

    # Les ficheirs distants doivent être détruits
    if dis_files.count > 0
      report "Nombre de fichiers DISTANTS à détruire : #{dis_files.count} "
      dis_files.each do |relpath, ctime|
        # On met une protection, au cas où
        unless relpath.nil_if_empty.nil? || relpath == '/'
          dis_fullpath = "#{dis_cnarration_folder}/#{relpath}"
          rs = `ssh #{serveur_ssh} 'rm #{dis_fullpath}'`
          report "= Fichier #{relpath} DISTANT détruit avec succès"
        end
      end
    else
      report "Aucun fichiers distants à détruire."
    end


    report "= Synchronisation des fichiers physiques OK"
  end

  # ---------------------------------------------------------------------
  #   SOUS-MÉTHODES DE SYNCHRONISATION
  # ---------------------------------------------------------------------

  # Actualisation d'un fichier ERB distant
  #
  def upload_narration_file relpath
    loc_fullpath = "#{loc_cnarration_folder}/#{relpath}"
    File.exist?(loc_fullpath) || raise("Le fichier local `#{loc_fullpath}` est introuvable…")
    dis_fullpath = "#{dis_cnarration_folder}/#{relpath}"
    cmd_scp = "scp -pv '#{loc_fullpath}' #{serveur_ssh}:#{dis_fullpath}"
    retour = `#{cmd_scp}`
    suivi retour
  end

  # Dossier narration local
  def loc_cnarration_folder
    @loc_cnarration_folder ||= './data/unan/pages_semidyn/cnarration'
  end
  # Dossier narration distant
  def dis_cnarration_folder
    @dis_cnarration_folder ||= './www/data/unan/pages_semidyn/cnarration'
  end

  # ---------------------------------------------------------------------
  #   SOUS MÉTHODES
  # ---------------------------------------------------------------------


  # Méthode qui récupère les données des fichiers online.
  # C'est simplement un Hash contenant en clé le path du fichier
  # distant et en valeur sa date de modification.
  def get_fichiers_distants
    code_ssh = <<-SSH
res = {error: nil, files: nil}
begin
  h_files = {}
  main_folder = './www/data/unan/pages_semidyn/cnarration'
  Dir[main_folder + '/**/*.*'].collect do |pany|
    relpath = pany.sub(/^\\.\\/www\\/data\\/unan\\/pages_semidyn\\/cnarration\\//,'')
    h_files.merge!( relpath => File.stat(pany).mtime.to_i )
  end
  res[:files] = h_files
rescue Exception => e
  res[:error] = e.message
end
STDOUT.write Marshal::dump(res)
    SSH
    rs = `ssh #{serveur_ssh} "ruby -e \\"#{code_ssh}\\""`
    if rs == ''
      raise "Impossible d'obtenir la liste des fichiers distants : retour SSH vide…"
    else
      rs = Marshal.load(rs)
      if rs[:error].nil?
        rs[:files]
      else
        raise "Impossible d'obtenir la liste des fichiers distants : #{rs[:error]}"
      end
    end
  end

  def get_fichiers_locaux
    h_files = {}
    main_folder = './data/unan/pages_semidyn/cnarration'
    Dir[main_folder + '/**/*.*'].collect do |pany|
      relpath = pany.sub(/^#{main_folder}\//,'')
      h_files.merge!( relpath => File.stat(pany).mtime.to_i )
    end
    h_files
  end

  # Pour actualiser le niveau de développement d'une page
  def update_niveau_developpement(pid, loc_data, dis_data)
    loc_niv = loc_data[:options][1].to_i
    dis_niv = dis_data[:options][1].to_i
    if loc_niv > dis_niv
      dis_table.update(pid, {options: loc_data[:options]})
      report "Niveau de développement de ##{pid} passé à #{loc_niv}"
    else
      loc_table.update(pid, {options: dis_data[:options]})
      report "Niveau de développement de ##{pid} passé à #{dis_niv}"
    end
  end

  def db_suffix   ; @db_suffix  ||= :cnarration end
  def table_name  ; @table_name ||= 'narration' end


  # Adresse du serveur SSH sous la forme "<user>@<adresse ssh>"
  # Note : Défini dans './objet/site/data_synchro.rb'
  def serveur_ssh
    @serveur_ssh ||= begin
      require './objet/site/data_synchro.rb'
      Synchro::new().serveur_ssh
    end
  end
  alias :serveur_ssh_boa :serveur_ssh


end #/CNarration

# Pour la table 'tdms'
# Usage Sync::TDMNarration.instance.loc_table ou dis_table, etc.
class TDMNarration
  include Singleton
  include CommonSyncMethods

  # Retourne le nombre de synchronisations
  def synchronize sync
    @sync = sync

    nombre_synchronisations = 0

    loc_rows.each do |rid, loc_data|
      dis_data = dis_rows[rid]
      # suivi "#{loc_data.inspect} / #{dis_data.inspect}"
      if loc_data != dis_data
        if dis_data[:updated_at] > loc_data[:updated_at]
          dis_data.delete(:id)
          loc_table.update(rid, dis_data)
        else
          loc_data.delete(:id)
          dis_table.update(rid, loc_data)
        end
        nombre_synchronisations += 1
      else
        # Les deux données sont identiques, rien à faire
      end
    end

    return nombre_synchronisations
  end

  def db_suffix   ; @db_suffix  ||= :cnarration end
  def table_name  ; @table_name ||= 'tdms'      end
end #/TDMNarration
end #/Sync
