# encoding: UTF-8
class Sync

  # = main =
  #
  # Méthode principale appelée lorsque l'on demande la synchronisation
  # des fichiers cochés.
  def synchronize
    @suivi = Array::new

    flash "Je synchronise tout ce qu'il y a à synchroniser."
    return

    # Faut-il synchroniser les affiches sur Icare ?
    synchronize_affiches_on_icare if param(:cb_synchronize_affiches)

  end

  # Relève le données de synchronisation dans le
  # fichier `sync_data_file`
  #
  # Les données de synchronisation ne sont pas à confondre avec les
  # données de check (cf. introduction)
  def data_synchronisation
    @data_synchronisation ||= begin
      synchro_data_path.exist? ? Marshal::load(synchro_data_path.read) : Hash::new
    end
  end

  # Enregistre les données de synchronisation
  # Noter que cette méthode est appelée par la méthode `build_inventory`
  # dans le module `display_methods.rb` car c'est elle qui fait l'analyse
  # des synchronisations à opérer.
  def data_synchronisation= d
    synchro_data_path.remove if synchro_data_path.exist?
    @data_synchronisation = d
    synchro_data_path.write Marshal::dump(d)
  end

  # ---------------------------------------------------------------------
  #   Méthodes de synchronisation
  # ---------------------------------------------------------------------

  def synchronize_affiches_on_icare
    uploads = data_synchronisation[:affiches_icare][:upload_on_icare]
    deletes = data_synchronisation[:affiches_icare][:delete_on_icare]

    # Uploader les affiches
    uploads.each do |affiche_name|
      local_path = File.expand_path(File.join('.', 'view', 'img', 'affiches', affiche_name))
      raise "L'affiche `#{local_path}` devrait exister !" unless File.exist?(local_path)
      distant_path = File.join('.', 'www', 'img', 'affiches', affiche_name)
      cmd = "scp -p #{local_path} #{serveur_ssh_icare}:#{distant_path}"
    end

  end

end #/Sync
