# encoding: UTF-8
=begin

À FAIRE :

  1. Implémenter la synchronisation proprement dite
      - ne pas oublier de détruire les fichiers de synchronisation
        mais après l'opération
      - les affiches
      - chaque fichier avec son traitement spécial
      
  2. Incorporer les fichiers de Narration dans le check, mais il
     faut au préalable voir comment ils fonctionnent sur Icare et
     synchroniser le fonctionnement.

=end

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
