# encoding: UTF-8
=begin
  Module définissant toutes les opérations possibles (qui peuvent
  être atteintes par les boutons principaux)
=end
class SyncRestsite

  # Les extensions de fichiers qui sont étudiées
  VALID_EXTNAMES = ['.rb', '.md']

class << self

  # = main =
  #
  # Méthode principale procédant à la comparaison des deux
  # dossiers d'applications choisies
  #
  def proceed_compare
    applications_ok_or_raise
    # Pour mettre les lignes de rapport
    @report = Array.new
    # Pour mettre les données de synchronisation
    @data_synchronisation = Hash.new
    @liste_paths_traited = Hash.new

    # === COMPARAISON ===
    compare_folder nil

    # === Enregistrement du fichier marshal provisoire ===
    # Ce fichier contient toutes les informations sur les
    # désynchronisation.
    @data_synchronisation.empty? || begin
      desync_file = app_source.path + 'tmp/desync_file'
      h = Hash.new
      @data_synchronisation.each do |relp, isync|
        h.merge!(relp, isync.data)
      end
      desync_file.write Marshal.dump(h)
    end

  end


  def compare_folder folder
    # Voir s'il faut traiter ce dossier
    if app_source.folders_out.include?(folder)
      @report << "&lt;-- Dossier source exclu : #{folder}"
      return
    end
    if app_destination.folders_out.include?(folder)
      @report << "&lt;-- Dossier destination exclu : #{folder}"
    end
    folder_src, folder_dst =
      if folder.nil?
        [app_source.path, app_destination.path]
      else
        [app_source.path+folder, app_destination.path+folder]
      end

    # debug "folder_src: #{folder_src}"
    # debug "folder_dst: #{folder_dst}"
    Dir["#{folder_src}/*"].each do |p|
      @liste_paths_traited.merge!(p => true)
      traite_file_or_folder(p, folder_src, folder_dst)
    end
    Dir["#{folder_dst}/*"].each do |p|
      # Pour ne traiter que les paths non traités par la boucle
      # précédente
      @liste_paths_traited.key?(p) && next
    end
  end

  def traite_file_or_folder p, dos_src, dos_dst
    pname = File.basename(p)
    path_src = dos_src + pname
    path_dst = dos_dst + pname
    rel_path = path_src.to_s.sub(/^#{app_source.path}\//,'')
    @report << "--- Étude de : #{rel_path.inspect}"

    if app_source.exclude? rel_path
      @report << "    &lt;- Dossier source exclu"
      return
    end
    if app_destination.exclude? rel_path
      @report << "    &lt;- Dossier destination exclu"
      return
    end

    if File.directory?(path_src)
      compare_folder(rel_path)
    elsif VALID_EXTNAMES.include?(File.extname(p))
      # === COMPARAISON D'UN FICHIER ===
      compare_files path_src, path_dst, rel_path
    else
      # Rien à faire avec ce path
      @report << '    &lt;- Fichier écarté (extension)'
    end
  end

  def compare_files src, dst, rel_path
    @report << "    Comparaison de : #{rel_path}"
    data_sync_src2dst = {from: src.path, vers: dst.path, sens: :normal,   rel_path: rel_path, raison: nil}
    data_sync_dst2src = {from: dst.path, vers: src.path, sens: :inverse,  rel_path: rel_path, raison: nil}
    if dst.exist? && src.exist?
      @report << "    Fichier source et destination existent"
      if dst.mtime == src.mtime
        @report << "    = À jour"
      elsif dst.mtime < src.mtime
        @data_synchronisation.key?(src.path) || begin
          newsync = SyncRestsite::Sync.new(data_sync_src2dst.merge(raison: :outofdate))
          @data_synchronisation.merge!(src.path => newsync)
        end
      else
        @data_synchronisation.key?(dst.path) || begin
          newsync = SyncRestsite::Sync.new(data_sync_dst2src.merge(raison: :outofdate))
          @data_synchronisation.merge!(dst.path => newsync)
        end
      end
    elsif false == src.exist?
      @data_synchronisation.key?(dst.path) || begin
        @report << "    Fichier source inexistant"
        newsync = SyncRestsite::Sync.new(data_sync_dst2src.merge(raison: :unknown))
        @data_synchronisation.merge!(dst.path => newsync)
      end
    elsif false == dst.exist?
      @data_synchronisation.key?(src.path) || begin
        @report << "    Fichier destination inexistant"
        newsync = SyncRestsite::Sync.new(data_sync_src2dst.merge(raison: :unknown))
        @data_synchronisation.merge!(src.path => newsync)
      end
    end
  end


end #/<< self
end #SyncRestsite
