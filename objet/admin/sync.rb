# encoding: UTF-8
=begin

  Ce module permet de procéder à une synchronisation intelligente
  des fichiers et bases de données entre le site distant et local.
  Elle est "intelligente" dans le sens où elle tient compte des
  modifications qui peuvent avoir été faites des deux côtés.
  Elle est intelligente aussi parce qu'elle vérifie aussi tous les
  fichiers, que ce soit les pages d'analyse, les pages de cours ou
  les affiches de film.

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
