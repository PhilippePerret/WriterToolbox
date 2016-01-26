# encoding: UTF-8
=begin

Méthodes pratiques de haut niveau

=end
site.require_objet 'unan'
Unan::require_module 'page_cours'

# Return une instance Unan::Program::PageCours d'une page de cours
# +page_ref+ Soit l'id {Fixnum} soit l'handler ({Symbol}) de la page
def page_cours page_ref
  case page_ref
  when Symbol then Unan::Program::PageCours::get_by_handler page_ref
  when Fixnum then Unan::Program::PageCours::get page_ref
  else
    raise "Une page de cours doit être demandée avec la méthode pratique `page_cours()` soit par son handler (`Symbol`) soit par son ID (`Fixnum`)."
  end
end
