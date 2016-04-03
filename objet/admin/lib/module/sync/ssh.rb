# encoding: UTF-8
class Sync

  # Adresse du serveur SSH sous la forme "<user>@<adresse ssh>"
  # Note : Défini dans './objet/site/data_synchro.rb'
  def serveur_ssh
    @serveur_ssh ||= begin
      require './objet/site/data_synchro.rb'
      Synchro::new().serveur_ssh
    end
  end

  def serveur_ssh_icare
    @serveur_ssh_icare ||= "icare@ssh-icare.alwaysdata.net"
  end

  def script_to_command script
    script.split("\n").collect do |line|
      next nil if line.start_with?('#')
      line.strip
    end.compact.join(';')
  end

  # Script pour checker la synchro sur BOA distant et
  # retourner le résultat.
  def script_check_synchro
    <<-CODE
VIA_SSH = true
res = nil
begin
  require './www/objet/admin/sync.rb'
  res = sync.etat_des_lieux
rescue Exception => e
  res = {err_time:Time.now.to_i, err_mess:e.message, err_backtrace:e.backtrace}
end
res.merge!('.' => File.expand_path('.'), 'folders' => Dir['./**'].collect{|p| File.basename(p)}.join(','))
STDOUT.write Marshal::dump( res )
    CODE
  end

  # Script pour checker sur icare les affiches, les bases
  # 
  def script_check_icare
    <<-CODE
errors = Array::new
res = Hash::new
res = {errors: Array::new}
{
  narration:'narration/cnarration.db',
  scenodico:'db/scenodico.db',
  filmodico:'db/filmodico.db'}.each do |key, rpath|
  begin
    fpath = File.join('./www/storage', rpath)
    res.merge!(key => {mtime: File.stat(fpath).mtime.to_i})
  rescue Exception => e
    res[:errors] << ('Problème avec ' + rpath + ' : ' + e.message)
  end
end
# On vérifie les affiches en prenant la liste des
# affiches
liste_affiches = Dir['./www/img/affiches/*.jpg'].collect{|p| File.basename(p)}.join(',')
res.merge!(affiches: liste_affiches)
# On retourne le hash de données marshalisé
(STDOUT.write Marshal::dump res)
    CODE
  end

end #/Sync
