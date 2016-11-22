# encoding: UTF-8
=begin

  Module appelé pour éditer le texte d'un fichier narration.
  L'ID est dans objet_id de la route.

  Seul l'administrateur peut jouer cette route.

=end
raise_unless_admin


def ipage
  @ipage ||= Cnarration::Page.new(site.current_route.objet_id)
end
param(path: ipage.fullpath)
param(snippets_narration: 'on')
redirect_to "site/edit_text"
