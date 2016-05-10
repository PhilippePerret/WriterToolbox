# encoding: UTF-8
=begin

Module pour la construction du manuel PDF

=end
site.require_gem 'latexbook'
ibook = LaTexBook::new((site.folder_objet+"analyse/manuel/latexbook"))
okbuild = ibook.build
debug "\n\n#{ibook.suivi}\n\n"

if okbuild == true
  flash "Manuel analyse construit avec succès."
else
  error "Problème en construisant le manuel (consulter le log)"
end
