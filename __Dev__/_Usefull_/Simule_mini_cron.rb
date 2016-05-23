# encoding: UTF-8
=begin
  Pour simuler l'appel du mini-cron qui vérifie principalement que les pages
  minimum du site distant soit accessibles et retourne un mail administrateur
  en cas d'erreur.

  Notes
    * Ce script est au maximum autonome. Il utilise par exemple l'auto-class
      MiniMail pour envoyer un mail minimal.

=end
FOLDER_CRON = '/Users/philippeperret/Sites/WriterToolbox/CRON'

# Pour l'utiliser, il faut faire comme le cron : se placer dans
# le dossier du cron
Dir.chdir(FOLDER_CRON) do
  require "#{FOLDER_CRON}/mini_cron.rb"
  # m = MiniMail.new
  # m.send("C'est l'été et ça se sent.\nPour voir sans rien.\nUne seconde ligne.")
end