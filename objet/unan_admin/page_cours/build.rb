# encoding: UTF-8
=begin

Module de construction de la page semi-dynamique.

Elle transforme notamment toutes les balises et laisse
uniquement les textes dynamiques de type %{variable} qui
seront traités à la volée au chargement de la page.

=end
class UnanAdmin
class PageCours

  # Le contenu dynamique qui va être construit à partir de
  # `content`, le contenu original de la page
  attr_reader :content_dyna

  def build_page_semi_dynamique
    debug "-> build_page_semi_dynamique"
    debug "#{fullpath} -> #{fullpath_semidyn}"

    @content_dyna = content.to_s

    corrige_balises_unan_unscript || return

    corrige_balises_pages_cours || return

    save_content_dynamique

    flash "Page ##{id} construite avec succès."
  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

  # Corriger les balises UN AN UN SCRIPT
  # Il s'agit des balises qui conduisent à d'autres travaux
  # [work::<id>::<titre>]
  def corrige_balises_unan_unscript
    debug "-> corrige_balises_unan_unscript"
    @content_dyna.gsub!(/\[work::([0-9]+)(::(.*?))?\]/){
      tout    = $0
      work_id = $1.to_i
      titre   = $3.nil_if_empty
      Unan::Program::AbsWork::get(work_id).lien_show(titre)
    }

  rescue Exception => e
    debug e
    error e
  else
    true # pour poursuivre
  end

  # Corriger les balises PAGES COURS
  # qui conduisent à d'autres pages de cours
  def corrige_balises_pages_cours
    debug "-> corrige_balises_pages_cours"

    @content_dyna.gsub!(/\[page::([0-9]+)(::(.*?))?\]/){
      tout    = $0
      page_id = $1
      titre   = $3.nil_if_empty
      "<a href='page_cours/#{page_id}/read?in=unan'>#{titre}</a>"
    }

  rescue Exception => e
    debug e
    error e
  else
    true # pour poursuivre
  end

  # Finalement, on peut enregistrer le contenu dynamique
  # dans son fichier
  def save_content_dynamique
    fullpath_semidyn.write content_dyna
  end

end #/PageCours
end #/UnanAdmin

# Avant de reconstruire la page, il faut la sauver
# Non : L'enregistrer avant, manuellement, car il y a un problème qui
# se pose pour le moment.
# Note : Je n'ai pas confiance en require_relative pour la version
# ruby 1.9 qui se trouve sur le site (et ma méthode est plus courte).
# require _"edit_content.rb"
# page_cours.update
# Ensuite, on peut construire la page semi-dynamique
page_cours.build_page_semi_dynamique
redirect_to :last_route
