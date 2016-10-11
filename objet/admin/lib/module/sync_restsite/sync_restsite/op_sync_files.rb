class SyncRestsite
class << self

  # Opération pour afficher la différence entre deux fichiers
  def sync_files
    @report = Array.new
    # Identifiant dans les données marshal
    sync_id = site.current_route.objet_id
    data_sync = Marshal.load(app_source.file_data_marshal.read)
    isync = Sync.new(data_sync[sync_id])

    from_linked = (isync.from).in_a(href: "site/open_file?app=atom&path=#{CGI.escape(isync.from)}", target: :new)
    vers_linked = (isync.vers).in_a(href: "site/open_file?app=atom&path=#{CGI.escape(isync.vers)}", target: :new)

    # En fonction du fait que l'opération a été confirmée ou non
    if param(:sync_files_confirmed) == 'ok'
      #
      # La synchronisation a été confirmée
      #
      # =============================================
      res = `cp -p "#{isync.from}" "#{isync.vers}"`
      # =============================================
      @report << "SYNCHRONISATION DE :"
      @report << from_linked
      @report << "VERS"
      @report << vers_linked
      @report << "OPÉRÉE AVEC SUCCÈS"
      @report << "(résultat : #{res})"
      flash "Synchronisation opérée avec succès (cf. ci-dessous)"
    else
      #
      # La synchronisation doit être confirmée
      #
      res_diff = `diff "#{isync.from}" "#{isync.vers}"`
      @report << "Confirmation de la synchronisation de ./#{isync.rel_path}"
      @report << "From : #{from_linked}"
      @report << "To   : #{vers_linked}"
      @report << "Différences : #{res_diff.force_encoding('utf-8')}"
      @report << form_confirmation_sync_files(sync_id)
    end

  end
  # /sync_files

  def form_confirmation_sync_files sync_id
    (
      'sync_files'.in_hidden(name: 'operation') +
      'ok'.in_hidden(name: 'sync_files_confirmed')+
      app_source.id.in_hidden(name: 'app_source') +
      app_destination.id.in_hidden(name: 'app_destination') +
      'Confirmer la synchronisation'.in_submit(class: 'btn').in_div(class: 'buttons')
    ).in_form(id: 'form_confirmation_sync_files', action: "admin/#{sync_id}/sync_restsite")
  end
  # /form_confirmation_sync_files

end #<< self
end #/SyncRestsite
