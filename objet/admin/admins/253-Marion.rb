# encoding: UTF-8
site.require_objet 'cnarration'
Cnarration::require_module 'cnarration'
class Cnarration
  class << self

    # Pages qui doivent faire l'objet d'une première relecture
    # avec relève des corrections (niveau de développement = 6)
    #
    # Retourne le code HTML d'une UL contenant les pages, avec
    # des boutons pour marquer les pages lues.
    def pages_a_relire options = nil
      @pars ||= begin
        pages(where: "options LIKE '16%'", as: :array_data, colonnes: [:titre])
      end
      if @pars.empty?
        "Aucune page n'est à relire pour le moment. Super, non ? :-)".in_div
      else
        @pars.collect do |hpage|
          (
            btns_page_edition(hpage, 7) +
            hpage[:titre]
          ).in_option(value: hpage[:id], class:'hover')
        end.join.in_ul(class: 'tdm')
      end
    end

    # Pages qui doivent faire l'objet d'une toute dernière lecture
    # (niveau 8 de développement)
    def pages_derniere_lecture options = nil
      @pdls ||= begin
        pages(where: "options LIKE '18%'", as: :array_data, colonnes: [:titre])
      end
      if @pdls.empty?
        "Aucune page n'est à relire pour BAT pour le moment. Super, non ? :-)".in_div
      else
        @pdls.collect do |hpage|
          (
            btns_page_edition(hpage, 9) +
            hpage[:titre]
          ).in_option(value: hpage[:id], class:'hover')
        end.join.in_ul(class: 'tdm')
      end

    end

    # Retourne le span HTML des boutons pour éditer
    # la page de la collection narration, pour la lire
    # et pour la marquer corrigée.
    # +hpage+ Données de la page (ici seulement le :titre et :id)
    # +new_dev_value+ La prochaine valeur de développement pour le
    # bouton qui permet d'incrémenter le niveau de développement de
    # la page
    def btns_page_edition hpage, new_dev_value
      pid = hpage[:id]
      (
        "Afficher".in_a(href:"page/#{pid}/show?in=cnarration", target: "_blank", class:'') +
        "<span> | </span>" +
        "Marquer corrigée".in_a(href:"page/#{pid}/set?in=cnarration&prop=nivdev&val=#{new_dev_value}", lass:'')
      ).in_span(class:'tiny fright btns')
    end

  end #/<<self
end #/Cnarration
