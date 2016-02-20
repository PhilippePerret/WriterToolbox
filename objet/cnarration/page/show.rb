# encoding: UTF-8
class Cnarration
class Page


  # = main =
  #
  # Méthode principale qui sort le contenu de la page
  def output
    case true
    when page?          then output_as_page
    when sous_chapitre? then output_as_sous_chapitre
    when chapitre?      then output_as_chapitre
    end
  end

  # {StringHTML} Sortie du code quand c'est une "vraie" page
  # donc pas un titre
  def output_as_page
    if false == path_semidyn.exist? || out_of_date?
      # La page semi-dynamique n'est pas encore construite, il
      # faut la construire. Pour ça, on utilise kramdown.
      (site.folder_objet+'cnarration/lib/module/page/build.rb').require
      build
    end
    if path_semidyn.exist?
      (
        titre.in_h3 +
        path_semidyn.deserb
      ).in_div(id:'page_cours')
    else
      error "Un problème a dû survenir, je ne trouve pas la page à afficher (semi-dynamique)."
    end
  end

  def output_as_sous_chapitre
    (
      "Sous-chapitre".in_div( class:'libelle_titre' ) +
      titre.in_div( class:'titre' )
    ).in_div( id:'page_titre' )
  end
  def output_as_chapitre
    (
      "Chapitre".in_div( class:'libelle_titre' ) +
      titre.in_div(class:'titre')
    ).in_div( id:'page_titre' )
  end

  # Retourne les boutons de navigation pour atteindre
  # les pages précédente et suivante
  def boutons_navigation where = :top
    ( lien_prev_page + lien_next_page ).in_div(class:"right nav #{where}")
  end
  def lien_prev_page
    visibility = prev_page_id.nil? ? 'hidden' : 'visible'
    (
      "←".in_a(href:"page/#{prev_page_id}/show?in=cnarration")
    ).in_div(style:"visibility:#{visibility}")
  end
  def lien_next_page
    visibility = next_page_id.nil? ? 'hidden' : 'visible'
    (
      "→".in_a(href:"page/#{next_page_id}/show?in=cnarration")
    ).in_div(style:"visibility:#{visibility}")
  end

  # ---------------------------------------------------------------------
  #   Pour trouver les ID de page après et avant

  # Retourne la liste des IDs de pages (qu'on met en session
  # au besoin)
  def tdm_ids
    @tdm_ids ||= begin
      app.session["cnarration_tdm#{livre_id}"] ||= livre.tdm.pages_ids
    end
  end

  # Index de la page courante dans la table des matières
  def index_tdm
    @index_tdm ||= begin
      tdm_ids.index(id)
    end
  end
  def prev_page_id
    @prev_page_id ||= begin
      index_prev = index_tdm - 1
      if index_prev < 0
        nil
      else
        tdm_ids[index_prev]
      end
    rescue
      nil
    end
  end
  def next_page_id
    @next_page_id ||= begin
      index_next = index_tdm + 1
      if index_next >= tdm_ids.count
        nil
      else
        tdm_ids[index_next]
      end
    rescue
      nil
    end
  end

end #/Page
end #/Cnarration
