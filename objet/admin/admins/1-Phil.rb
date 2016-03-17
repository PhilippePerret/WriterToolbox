# encoding: UTF-8
site.require_objet 'cnarration'
Cnarration::require_module 'cnarration'
class Cnarration
  class << self

    # Pages qui doivent faire l'objet d'une correction après la
    # première lecture de Marion ou autre lecteur
    # Retourne le code HTML d'une UL contenant les pages, avec
    # des boutons pour marquer les pages lues.
    def pages_a_corriger options = nil
      pars = pages(where: "options LIKE '17%'", as: :array_data, colonnes: [:titre])
      if pars.empty?
        "Aucune page n'est à corriger pour le moment. Super, non ? :-)".in_p
      else
        pars.collect do |hpage|
          (
            btns_page_edition(hpage, 8) +
            hpage[:titre]
          ).in_option(value: hpage[:id], class:'hover')
        end.join.in_ul(class: 'tdm')
      end
    end

    # Pages qui doivent faire l'objet d'une toute dernière correction et
    # être mise BAT.
    # (niveau 9 de développement)
    def pages_pour_bat options = nil
      pdls = pages(where: "options LIKE '19%'", as: :array_data, colonnes: [:titre])
      if pdls.empty?
        "Aucune page n'est à corriger pour BAT pour le moment. Super, non ? :-)".in_p
      else
        pdls.collect do |hpage|
          (
            btns_page_edition(hpage, 'a') +
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
