# encoding: UTF-8

# Ce module peut être appelé en standalone pour le check
# des synchros.
if defined?(VIA_SSH) && VIA_SSH
  # Si on est en distant par SSH
  ONLINE = true
  Dir['./www/objet/admin/lib/module/sync/**/*.rb'].each{|m| require m}
else
  # On passe par ici lorsque ce n'est pas SSH qui appelle le
  # module
  raise_unless_admin
  ::Admin::require_module 'sync'

  # Si une opération est à faire, il faut l'invoquer
  #
  if site.current_route.route == "admin/sync" && param(:operation) != nil
    methode = param(:operation).to_sym
    sync.send(methode) if sync.respond_to?( mathode )
  end
end

=begin
Class Sync
----------
Pour la gestion de la synchronisation générale du site
=end
class Sync

  # Retourne les mtime des fichiers à checker pour la synchro
  def file_mtimes
    @file_mtimes ||= begin
      res = Hash::new
      FILES2SYNC.each do |fid, fdata|
        fpath = fdata[:fpath]
        fpath = "./www/#{fpath}" if ONLINE
        res.merge!(fid => { mtime: File.stat(fpath).mtime.to_i })
      end
      res.merge!(date: Time.now.to_i)
      res
    end
  end

end # / Sync

def sync
  @sync ||= Sync.new
end
