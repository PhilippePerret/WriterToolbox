# encoding: UTF-8
=begin

Script qui affiche tous les mails qui n'ont pas été envoyés
en OFFLINE. Jouer CMD + i (dans Atom) ou CMD + r (dans TextMate)

RAPPEL : Ces mails ont été consignés au format Marshal dans
le dossier `./tmp/mails/`

=end

require './lib/required'

folder_mails = SuperFile::new('./tmp/mails')

Dir["#{folder_mails}/*.msh"].each do |path|
  path = SuperFile::new(path)
  data_mail = Marshal.load(path.read)
  puts data_mail.pretty_inspect
end
