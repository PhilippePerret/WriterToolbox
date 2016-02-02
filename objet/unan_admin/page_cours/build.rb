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
    @content_dyna.gsub!(/\[work::([0-9]+)(::.*?)?\]/){
      $0 = tout
      $1 = work_id
      $2 = titre # Peut-être nil
      "<a href='#{work_type}/#{work_id}/show?in=unan'>#{work_titre} (#{work_htype})</a>"
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


page_cours.build_page_semi_dynamique
redirect_to :last_route
