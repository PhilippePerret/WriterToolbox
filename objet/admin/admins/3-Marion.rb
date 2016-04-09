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
      pars = pages(where: "options LIKE '16%'", as: :array_data, colonnes: [:titre, :handler], sorted: true)
      if pars.empty?
        "Aucune page n'est à relire pour le moment. Super, non ? :-)".in_p
      else
        build_page_list pars, 7
      end
    end

    # Pages qui doivent faire l'objet d'une toute dernière lecture
    # (niveau 8 de développement)
    def pages_derniere_lecture options = nil
      pdls = pages(where: "options LIKE '18%'", as: :array_data, colonnes: [:titre, :handler], sorted: true)
      if pdls.empty?
        "Aucune page n'est à relire pour BAT pour le moment. Super, non ? :-)".in_p
      else
        build_page_list pdls, 9
      end
    end

    def build_page_list hdata, next_level
      hdata.collect do |bid, bdata|
        "Livre : #{bdata[:livre].titre}".in_li(class:'book_title') +
        bdata[:pages].collect { |hpage| li_for_page( hpage, next_level ) }.join('')
      end.join.in_ul(class: 'tdm pages books_discrets')
    end

    # Retourne le code HTML du LI pour une page à corriger
    def li_for_page hpage, next_level
      span_affixe = (
        "<br>Nom (sans extension) du fichier de correction : ".in_span +
        "p#{hpage[:id]}_#{hpage[:handler].gsub(/\//,'-')}_#{user.pseudo}".in_input_text(style:"width:320px", onfocus:"this.select()")
        ).in_span(class:'tiny')
      line_titre = ( hpage[:titre] + span_affixe ).in_span
      (btns_page_edition(hpage, next_level)+line_titre).in_li(value: hpage[:id], class:'hover')
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
