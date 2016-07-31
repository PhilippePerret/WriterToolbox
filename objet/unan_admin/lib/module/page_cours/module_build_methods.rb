# encoding: UTF-8
=begin

Module contenant les méthodes nécessaires pour construire les pages de cours
semi-dynamiques.

Ce module est utilisé par le programme UN AN aussi bien que par
la collection Narration pour le traitement de ses pages propres.

=end
module MethodesBuildPageSemiDynamique

  # Le contenu dynamique qui va être construit à partir de
  # `content`, le contenu original de la page
  attr_reader :content_dyna

  def build_page_semi_dynamique
    site.require_module 'kramdown'

    @content_dyna = content.to_s

    debug "@content_dyna : #{@content_dyna.gsub(/</,'&lt;')}"

    # @content_dyna = @content_dyna.mef_document(output_format = :html)
    # @content_dyna = @content_dyna.formate_balises_propres

    # corrige_balises_unan_unscript || return
    #
    # corrige_balises_pages_cours || return

    save_content_dynamique

    flash "Page ##{id} construite avec succès."
  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

  # Corriger les balises UN AN
  # Il s'agit des balises qui conduisent à d'autres travaux
  # [work::<id>::<titre>]
  def corrige_balises_unan_unscript
    debug "-> corrige_balises_unan_unscript"
    @content_dyna.gsub!(/\[work::([0-9]+)(::(.*?))?\]/){
      tout    = $0
      work_id = $1.to_i
      titre   = $3.nil_if_empty
      Unan::Program::AbsWork.get(work_id).lien_show(titre)
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
      "<a href='page_cours/#{page_id}/show?in=unan'>#{titre}</a>"
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

end
