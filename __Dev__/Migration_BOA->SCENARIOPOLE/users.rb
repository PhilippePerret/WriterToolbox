# encoding: UTF-8
=begin

  Script pour faire passer les users de BOA dans la base de SCENARIOPOLE

  Note : il faut tenir une table de correspondance pour connaitre l'ID de l'user
  dans BOA et son nouvel ID dans SCENARIOPOLE (qu'il soit créé ou non) pour
  pouvoir, notamment, modifier les ID des users dans les résultats des quiz

=end

THISFOLDER = File.dirname(__FILE__)
# puts "THISFOLDER = #{THISFOLDER}"

require 'mysql2'
require './data/secret/mysql.rb'
# data_MySql = DATA_MYSQL[:offline]
data_MySql = DATA_MYSQL[:online]
client = Mysql2::Client.new(data_MySql)
clientSce = Mysql2::Client.new(data_MySql.merge!(database:'scenariopole_hot'))

# On récupère tous les users dans la base de BOA
users_boa = []
client.query("SELECT * FROM scenariopole_boa_hot.users", :symbolize_keys => true).each do |udata|
  users_boa << udata
end

# On récupère tous les users dans la base de SCÉNARIOPOLE
users_sce_by_mail = {}
users_sce_by_pseudo = {}
client.query("SELECT * FROM scenariopole_hot.users", :symbolize_keys => true).each do |udata|
  users_sce_by_mail.merge!(udata[:mail] => udata)
  users_sce_by_pseudo.merge!(udata[:pseudo] => udata)
end

puts "users_sce_by_mail = #{users_sce_by_mail}"

cols = ['pseudo','patronyme','mail','cpassword','salt','options','sexe','address','telephone','updated_at','created_at']
ints = cols.collect{|c| '?'}
cols = cols.collect{|c| c.to_sym}
create_stat = "INSERT INTO `users` (#{cols.join(', ')}) VALUES (#{ints.join(', ')})"
create_stat = clientSce.prepare(create_stat)

# puts create_stat
# exit(0)

users_boa.each do |udata|
  if udata[:pseudo].strip == ''
    puts "L'utilisateur ##{udata[:id]} n'a pas de pseudo, on le supprime."
    next
  end
  puts "--- udata = #{udata}"
  if users_sce_by_mail.key?(udata[:mail].downcase)
    puts "L'utilisateur #{udata[:pseudo]} est connu sur scénariopole (par son mail)"
    udata[:scenariopole_id] = users_sce_by_mail[udata[:mail].downcase][:id]
  elsif users_sce_by_pseudo.key?(udata[:pseudo])
    puts "L'utilisateur #{udata[:pseudo]} est connu sur scénariopole (par son pseudo)"
    udata[:scenariopole_id] = users_sce_by_pseudo[udata[:pseudo]][:id]
  else
    puts "L'utilisateur #{udata[:pseudo]} n'est pas connu sur scénariopole et doit être créé."

    values = cols.collect{|col| udata[col]}
    puts "values : #{values}"

    # LE CRÉER ICI
    create_stat.execute(*values)

    udata[:scenariopole_id] = clientSce.query("SELECT LAST_INSERT_ID()").first.values.first

  end
end

puts "users_boa: #{users_boa.inspect}"


str = "\n\n\n\n=== TABLE DE CORRESPONDANCE DES IDS ===\n\n"
users_boa.each do |udata|
  udata[:pseudo] != '' || next
  str << "   #{udata[:pseudo].ljust(20)} #{udata[:id].to_s.ljust(4)} -> #{udata[:scenariopole_id]}\n"
end

puts str

File.open(File.join(THISFOLDER,'idboa2idscenariopole.txt'),'wb'){|f|f.write str}
