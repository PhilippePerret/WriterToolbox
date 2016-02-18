# encoding: UTF-8
class Cnarration
class Page

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
      # TODO Il faudrait ne mettre que les pages qui sont
      # vraiment des pages, pas les chapitres et sous-chapitres
      app.session["cnarration_tdm#{livre_id}"] ||= livre.tdm.pages_ids
    end
  end

  # Index de la page courante dans la table des matières
  def index_tdm
    @index_tdm ||= begin
      debug "tdm_ids: #{tdm_ids.inspect}"
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
    end
  end

end #/Page
end #/Cnarration
