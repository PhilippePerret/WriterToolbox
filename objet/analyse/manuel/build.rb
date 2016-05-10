# encoding: UTF-8
=begin

Module pour la construction du manuel PDF

=end
site.require_gem 'latexbook'
lien.output_format = :markdown
ibook = LaTexBook::new((site.folder_objet+"analyse/manuel/latexbook"))
okbuild = ibook.build
debug "\n\n#{ibook.suivi}\n\n"

if okbuild == true
  flash ibook.message
else
  error ibook.error
end
