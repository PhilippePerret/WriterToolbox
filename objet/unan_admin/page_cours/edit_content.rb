# encoding: UTF-8
=begin

Extension de la class UnanAdmin::PageCours et ses méthods d'instance
pour l'actualisation du code de la page originale.

=end
class Unan
class Program
class PageCours

  # Actualiser le contenu de la page
  def update
    corrige_content
    # Faire un backup du fichier actuel
    fullpath_backup.write fullpath.read
    # Enregistrer le nouveau contenu
    fullpath.write content
    flash "Page ##{id} enregistrée dans son fichier."
  rescue Exception => e
    fullpath.remove if fullpath.exist?
    fullpath.write fullpath_backup.read
    error "Un problème est survenu, j'ai remis le texte original."
  else
    # On peut détruire le backup
    fullpath_backup.remove if fullpath_backup.exist?
    # Actualisation de la date de dernière modification
    set(updated_at: NOW)
  end

  # Correction du contenu.
  # Noter qu'il s'agit seulement ici de quelques corrections, pas de la
  # construction de la page semi-dynamique qui sera opéré par le module
  # build.rb
  def corrige_content
    texte = param(:page_cours)[:content]
    texte.gsub(/\r/, '') if texte.match("\n")
    @content = texte
  end

end #/PageCours
end #/Program
end #/Unan


case param(:operation)
when 'save_page_content'
  page_cours.update
end
