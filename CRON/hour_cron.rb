# encoding: UTF-8
=begin
Module qui doit être appelé toutes les heures par le cron-job.

NOTE : Il doit être exécutable.

=end
def safed_log mess
  File.open("#{THIS_FOLDER}/safed_log.log", 'a') do |f|
    f.write "#{mess}\n"
  end rescue nil
end
THIS_FOLDER = File.dirname(__FILE__)
File.open("#{THIS_FOLDER}/safed_log.log", 'wb') do |f|
  f.write "SAFED LOG DU #{Time.now.strftime('%d %m %Y - %H:%M')}\n(Si ce fichier existe, c'est qu'un problème est survenu et que le cron n'a pas pu être exécuté jusqu'au bout.\n"
end
require File.join(THIS_FOLDER, 'lib', 'required.rb')

# Si on est arrivé là, on peut détruire le safed-log
# File.unlink("#{THIS_FOLDER}/safed_log.log") if File.exist?('./safed_log.log')
