# encoding: UTF-8
=begin

Méthodes pour l'affichage de la page

=end
Unan::require_module 'page_cours'

class Unan
class Program
class PageCours

  # Sortie complète de la page de cours à écrire dans la page
  # Note : Ajoute également une lecture à l'user.
  def output options = nil
    # Cas spécial de l'administrateur visitant cette page
    if user.admin? && !user.unanunscript?
      # On prend Benoit
      return 'Cette page doit être lue par Benoit pour être affichée.'.in_div(class: 'warning')
    end
    user.add_lecture_page_cours(self) if user.unanunscript?
    titre.in_h2 + read
  rescue Exception => e
    debug e
    "[IMPOSSIBLE D'AFFICHER LA PAGE ##{id} - Elle ne semble pas exister]"
  end
end #/PageCours
end #/Program
end #/Unan

def page_cours
  @page_cours ||= Unan::Program::PageCours::get(site.current_route.objet_id)
end

class User
  # Ajoute une lecture pour la page +ipage+ {Unan::Program::PageCours}
  def add_lecture_page_cours ipage
    # L'auteur n'a pas forcément d'enregistrement pour cette page,
    # mais la méthode `add_lecture` le vérifie et crée la page s'il
    # le faut (note : on parle bien du record pour l'user, pas de la
    # page elle-même, qui doit exister. Mais pour chaque page de cours,
    # on fait un enregistrement propre à l'user dans sa table 'pages_cours'
    # où sont consignées ses informations)
    upage = User::UPage::get(self, ipage.id)
    upage.add_lecture
    upage.set_lue unless upage.lue?
  end
end #/User
