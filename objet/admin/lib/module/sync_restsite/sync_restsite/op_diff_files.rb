class SyncRestsite
class << self

  # Opération pour afficher la différence entre deux fichiers
  def diff_files
    @report = Array.new
    # Identifiant dans les données marshal
    sync_id = site.current_route.objet_id

    data_sync = Marshal.load(app_source.file_data_marshal.read)
    isync = Sync.new(data_sync[sync_id])

    res_diff = `diff "#{isync.from}" "#{isync.vers}"`

    from_linked = (isync.from).in_a(href: "site/open_file?app=atom&path=#{CGI.escape(isync.from)}", target: :new)
    vers_linked = (isync.vers).in_a(href: "site/open_file?app=atom&path=#{CGI.escape(isync.vers)}", target: :new)
    @report << "From : #{from_linked}"
    @report << "To   : #{vers_linked}"
    @report << "Diff : \n#{res_diff}"
    flash "Différence entre les fichiers de la données ##{sync_id} (#{isync.rel_path})"
  end

end #<< self
end #/SyncRestsite
