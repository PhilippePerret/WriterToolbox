# encoding: UTF-8
=begin

Tout ce qu'il y a à requérir pour le cron

=end
log "-> lib/required.rb"

# Requérir tout le dossier ./lib/required
Dir["#{THIS_FOLDER}/lib/required/**/*.rb"].each{|m| require m}


log "<- lib/required.rb"
