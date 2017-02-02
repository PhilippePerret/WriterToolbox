# encoding: utf-8
=begin

Méthodes pour l'affichage de la page

=end
raise_unless user.unanunscript? || user.admin?

Unan.require_module 'page_cours'

class Unan
class Program
class PageCours

  # Sortie complète de la page de cours à écrire dans la page
  # Note : Ajoute également une lecture à l'user.
  def output options = nil
    # Cas spécial de l'administrateur visitant cette page
    if !user.unanunscript?
      # On prend Benoit
      flash 'Cette page est lue par Benoit pour être affichée correctement.'
      user_init_id = user.id.freeze
      User.current = Unan.auteurs(as: :instance).first # User.get(2)
    else
      user_init_id = nil
    end
    # Peut-être faut-il reconstruire la page, si elle a été
    # modifié dans un éditeur externe.
    rebuild_page_cours if page_out_of_date?

    # Enfin, on peut renvoyer le texte de la page et son
    # titre pour affichage.
    titre.in_h2 + read.formate_balises_propres

  rescue Exception => e
    debug e
    "[IMPOSSIBLE D'AFFICHER LA PAGE : ##{id} : #{OFFLINE ? e.message : ''}]"
  ensure
    # On remet l'utilisateur initial (pour construire l'affichage courant
    # de la page, lorsque c'était un administrateur qui visitait la page
    # on a dû utiliser un vrai auteur du programme).
    user_init_id.nil? || User.current = User.get(user_init_id)
  end

  # RETURN true si la page n'est pas à jour.
  #
  # On le sait en comparant la date de la page qui contient le
  # code original avec la page semi-dynamique.
  #
  # Noter que ça n'arrive que lorsque la page est édité dans un
  # éditeur externe, sinon, la page est actualisée automatiquement
  #
  def page_out_of_date?
    fullpath_semidyn.exist? || (return true)
    fullpath.mtime > fullpath_semidyn.mtime
  end

  # Méthode qui demande la reconstruction de la page si elle
  # n'est pas à jour
  def rebuild_page_cours
    flash 'Reconstruction de la page semi-dynamique…'
    # Il faut charger le module administration de construction d'une
    # page semi-dynamique.
    SuperFile.new('./objet/unan_admin/lib/module/page_cours/module_build_methods.rb').require
    SuperFile.new('./objet/unan_admin/lib/required/page_cours').require
    extend MethodesBuildPageSemiDynamique
    build_page_semi_dynamique
  end

end #/PageCours
end #/Program
end #/Unan

def page_cours
  @page_cours ||= Unan::Program::PageCours.get(site.current_route.objet_id)
end
