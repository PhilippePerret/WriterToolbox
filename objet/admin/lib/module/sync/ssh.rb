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
  alias :serveur_ssh_boa :serveur_ssh

  def serveur_ssh_icare
    @serveur_ssh_icare ||= "icare@ssh-icare.alwaysdata.net"
  end

  # Script pour checker la synchro sur BOA distant et
  # retourner le résultat.
  def script_check_boa
    <<-CODE
begin
VIA_SSH = true
res = nil
begin
  require './www/objet/admin/sync.rb'
  res = sync.etat_des_lieux
rescue Exception => e
  res = {err_time:Time.now.to_i, err_mess:e.message, err_backtrace:e.backtrace}
end

# On prend aussi les affiches, comme sur Icare
liste_affiches = Dir['./www/view/img/affiches/*.jpg'].collect{|p| File.basename(p)}.join(',')
res.merge!(affiches: liste_affiches)
res.merge!('.' => File.expand_path('.'), 'folders' => Dir['./**'].collect{|p| File.basename(p)}.join(','))

# On regarde aussi les fichiers Narration, comme sur ICARE
# La donnée générale concernant la collection narration, exceptée
# la base qui est checkée ci-dessus
data_cnarration = Hash::new

# On vérifie les fichiers CSS du dossier ce la collection Narration
h_css = Hash::new
Dir['./objet/Cnarration/lib/required/css/**/*.css'].each do |pcss|
  h_css.merge!(File.basename(pcss) => File.stat(pcss).mtime.to_i)
end
data_cnarration.merge!( :css => h_css )

# On vérifie tous les fichiers Narration.
begin
  h_files = Hash::new
  main_folder = './www/data/unan/pages_semidyn/cnarration'
  Dir[main_folder + '/**/*.*'].collect do |pany|
    relpath = pany.sub(/^\\.\\/www\\/data\\/unan\\/pages_semidyn\\/cnarration\\//,'')
    h_files.merge!( relpath => File.stat(pany).mtime.to_i )
  end
  data_cnarration.merge!( :files => h_files )
rescue Exception => e
  errors << e.message
end
res.merge!(cnarration: data_cnarration)

# Le rescue principal
rescue Exception => e
  res ||= Hash::new
  res.merge!(error: {err_message: e.message, err_backtrace:e.backtrace})
end

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
begin
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

# La donnée générale concernant la collection narration, exceptée
# la base qui est checkée ci-dessus
data_cnarration = Hash::new

# On vérifie les fichiers CSS du dossier ce la collection Narration
h_css = Hash::new
Dir['./www/ruby/_apps/Cnarration/view/css/**/*.css'].each do |pcss|
  h_css.merge!(File.basename(pcss) => File.stat(pcss).mtime.to_i)
end
data_cnarration.merge!( :css => h_css )

# On vérifie tous les fichiers Narration.
begin
  h_files = Hash::new
  './www/storage/narration/cnarration'
  main_folder = './www/storage/narration/cnarration'
  Dir[main_folder + '/**/*.*'].collect do |pany|
    relpath = pany.sub(/^\\.\\/www\\/storage\\/narration\\/cnarration\\//,'')
    h_files.merge!( relpath => File.stat(pany).mtime.to_i )
  end
  data_cnarration.merge!( :files => h_files )
rescue Exception => e
  errors << e.message
end
res.merge!(cnarration: data_cnarration)
res.merge!(errors: errors)

# Rescue du begin principal
rescue Exception => e
  res.merge!(error: {err_message:e.message, err_backtrace:e.backtrace})
end
# On retourne le hash de données marshalisé
(STDOUT.write Marshal::dump res)
    CODE
  end

end #/Sync
