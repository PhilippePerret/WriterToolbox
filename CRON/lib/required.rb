# encoding: UTF-8
=begin

Tout ce qu'il y a à requérir pour le cron.

Noter que cela ne charge pas le module du site ./lib/required
qui chargera toutes les librairies du site, ce qui sera fait plus tard

=end

# Requérir tout le dossier ./lib/required
Dir["#{THIS_FOLDER}/lib/required/**/*.rb"].each{|m| require m}


log "<- lib/required.rb"
