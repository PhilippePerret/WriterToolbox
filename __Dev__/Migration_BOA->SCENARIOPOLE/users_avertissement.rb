# encoding: UTF-8
=begin

  Script pour faire passer les users de BOA dans la base de SCENARIOPOLE

  Note : il faut tenir une table de correspondance pour connaitre l'ID de l'user
  dans BOA et son nouvel ID dans SCENARIOPOLE (qu'il soit créé ou non) pour
  pouvoir, notamment, modifier les ID des users dans les résultats des quiz

=end
class String
  def nil_if_empty
    return self === '' ? nil : self
  end
end#/String

THISFOLDER = File.dirname(__FILE__)
# puts "THISFOLDER = #{THISFOLDER}"

require 'erb'
require 'mysql2'
require './data/secret/mysql.rb'

require '/Users/philippeperret/Sites/SCENARIOPOLE/__SITE__/_config/data/secret/data_mail.rb'
# => DATA_MAIL et MY_SMTP
require '/Users/philippeperret/Sites/SCENARIOPOLE/lib/procedure/user/send_mail/module_mail_methods.rb'
# => Module MailModuleMethods
SENDMAIL_FOLDER = File.expand_path('../lib/procedure/user/send_mail')
File.exists?(SENDMAIL_FOLDER) || raise("Le dossier '#{SENDMAIL_FOLDER}' est introuvable…")
puts "SENDMAIL_FOLDER = #{SENDMAIL_FOLDER}"
Dir["#{SENDMAIL_FOLDER}**/*.rb"].each {|m| require m}

class MailSender
  def send
    self.class.send(message, to, from)
  end
  def customized_header
    return ''
  end
  def customized_footer
    return ''
  end
  def signature
    return ''
  end
end #/Mailsender

# Pour ne pas ajouter de <br> dans le message
CORRECT_RETURN_IN_MESSAGE = false

# data_MySql = DATA_MYSQL[:offline]
data_MySql = DATA_MYSQL[:online]
client = Mysql2::Client.new(data_MySql)
clientSce = Mysql2::Client.new(data_MySql.merge!(database:'scenariopole_hot'))

PSEUDO_LIST = File.join(THISFOLDER,'idboa2idscenariopole.txt')
pseudos = File.read(PSEUDO_LIST).strip.split("\n").collect{|l| l.split(' ')[0]}
puts "pseudos: #{pseudos}"
pseudos_as_list = pseudos.collect{|p| "'#{p}'"}.join(', ')
puts "pseudos_as_list : #{pseudos_as_list}"

# On récupère les données des users dans la base de SCÉNARIOPOLE

data_users = client.query("SELECT * FROM scenariopole_hot.users WHERE pseudo in (#{pseudos_as_list})", :symbolize_keys => true).collect do |udata|
  udata
end

MAILS_TEMP = <<-EOM
<p>Bonjour %{pseudo},</p>

<p>Ce message pour vous annoncer que le site <a href="http://www.laboiteaoutilsdelauteur.fr" style="text-decoration:none;">La Boite à Outils de l'Auteur</a> a maintenant été intégré au site <a href="http://www.scenariopole.fr" style="text-decoration:none;">Scenariopole</a> !</p>

<p>Votre inscription a été transférée sur le nouveau site, vous n'avez donc rien à faire.</p>

<p>Et vous pouvez vous connecter au site <a href="http://www.scenariopole.fr" style="text-decoration:none;">Scenariopole</a> avec les mêmes identifiants (votre mail %{mail} et votre mot de passe — que vous êtes %{f_le} seul%{f_e} à connaitre).</p>

<p>L’ancien site sera entièrement détruit sous peu. Pensez à modifier vos signets ! ;-)</p>

<p>En vous remerciant de votre attention,</p>
<p>Bien à vous,</p>
<p>Phil, administrateur du site Scenariopole
<br>------------------------------------------
<br><a href="mailto:phil@scenariopole.fr">phil@scenariopole.fr</a>
</p>
EOM

puts "data_users = #{data_users}"

# Envoi du mail à chaque user
data_users.each_with_index do |udata, idx|
  puts "udata[:sexe]: #{udata[:sexe]}"
  udata.merge!({
    f_e: udata[:sexe] == 'F' ? 'e' : '',
    f_le: udata[:sexe] == 'F' ? 'la' : 'le'
    })
  mail = MAILS_TEMP % udata

  data_mail = {
    message:  mail,
    subject:  "Migration vers SCENARIOPOLE",
    to:       udata[:mail],
    from:     'phil@scenariopole.fr',
    force_offline: true
  }
  MailSender.new(data_mail).send
  puts "Envoi à #{udata[:pseudo]} (##{udata[:id]} - #{udata[:mail]})"
  # puts mail

  # idx < 2 || break
end
