# encoding: utf-8
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
    #
    # OBSOLÈTE (maintenant, toute la collection est en libre accès)
    # Noter que la page est amputée, en sortie, si l'utilisateur
    # n'est pas abonné, et un message lui est fourni pour qu'il
    # s'abonne.
    #
    def output_as_page
      if user.admin? || path_semidyn.exist?
        (
          titre.in_h1                   +
          admin_avertissement_relecture +
          page_content_by_niveau_developpement
        ).in_div(id:'page_cours')
      else
        debug "Page semi-automatique introuvable : `#{path_semidyn}'"
        error 'Un problème a dû survenir, je ne trouve pas la page à afficher (semi-dynamique).'
      end
    rescue Exception => e
      debug e
      error e.message
    end

    def admin_avertissement_relecture
      if user.admin? && page_content_by_niveau_developpement.match(/<relecture>/)
        '<relecture>Attention, ce texte achevé ne demande qu’une relecture des passages qui se trouvent dans cette couleur.</relecture>'.in_div(class: 'cadre air big')
      else
        ''
      end
    end

    # Si le niveau de développement de la page est insuffisant, on
    # affiche un message de non lecture possible.
    # Le niveau de développement est fixé à 8 pour un lecteur
    # normal et à 6 pour un lecteur du programme UNAN
    # (TODO Quand toutes les pages de narration seront à un bon
    # niveau on pourra supprimer ça.)
    #
    # Noter que ça n'est pas ici qu'on vérifie l'accessibilité de
    # la page. Ici, on regarde juste le niveau de développement par
    # rapport au visiteur pour savoir si on affiche un message de niveau
    # insuffisant ou la page.
    #
    # OBSOLÈTE (maintenant, toutes les pages sont accessibles)
    # Ci-dessous, le fait d'utiliser @authorization_level plutôt
    # que `!user.admin?` permet d'utiliser l'autorisation par IP avec
    # authips à 1 dans l'url.
    #
    def page_content_by_niveau_developpement
      full_autorisation = user.admin? || user.authorization_level.to_i > 3
      if developpement < 8 && false == full_autorisation
        message_niveau_developpement_insuffisant
      else
        if false == path_semidyn.exist? || out_of_date?
          # La page semi-dynamique n'est pas encore construite, il
          # faut la construire. Pour ça, on utilise kramdown.
          Cnarration::require_module 'page'
          build
        end
        if developpement < 8
          'Noter que cette page ne se présente pas encore dans sa version définitive.'.in_div(class: 'red air', style: 'margin-bottom:4em;')
        else
          ''
        end + page_content_by_user
      end
    end

    # Le contenu de la page en fonction de l'abonnement
    # de l'user
    def page_content_by_user
      @full_page = path_semidyn.deserb

      # OBSOLÈTE
      # --------
      # (maintenant, la collection est en libre accès complet)
      # Si l'user est abonné ou que le texte fait moins de 3000
      # signes, on retourne le texte tel quel
      # return (full_page_with_exergue || @full_page) if user.authorized? || @full_page.length < 2500
      return full_page_with_exergue || @full_page

      # # OBSOLÈTE
      # # Si l'utilisateur n'est pas abonné, on tronque la page
      # # et on ajoute un message l'invitant à s'abonner.
      # # On a plusieurs moyens de tronquer la page :
      # #   - par la longueur (un tiers)
      # #   - par une longueur maximale si un tiers est trop long
      # #   - par une marque "stop" à un endroit précis
      # #
      # offset_mark_fin_extrait = @full_page.index('<!-- FIN EXTRAIT -->')
      # @full_page =
      #   if offset_mark_fin_extrait != nil
      #     debug "Mark de fin d'extrait trouvée à #{offset_mark_fin_extrait}"
      #     @full_page[0..offset_mark_fin_extrait - 1]
      #   else
      #     tiers_longueur = (@full_page.length / 3) - 100
      #     # Si le tiers n'est pas assez long, on l'augmente
      #     tiers_longueur = case true
      #                      when tiers_longueur < 1900 then 1900
      #                      when tiers_longueur > 2500 then 2500
      #                      else tiers_longueur
      #                      end
      #     # On cherche le premier double retour chariot suivant
      #     offset = @full_page.index("\n\n", tiers_longueur)
      #     # Si on en trouve pas, on garde 2900
      #     offset = 1900 if offset.nil?
      #
      #     @full_page[0..offset]
      #   end
      # return (full_page_with_exergue || @full_page) + " […]" + message_abonnement_required
    end

    # Si les paramètres contiennent :xmotex, c'est un mot
    # à mettre en exergue dans la page. Sinon, on retourne
    # le texte normal de la page normalement
    def full_page_with_exergue
      return false if param(:xmotex).nil?
      is_regular    = param(:xreg)    == '1'
      is_whole_word = param(:xww)     == '1'
      is_exact      = param(:xexact)  == '1'
      # On construit l'expression qu'on va envoyer à
      # with_exergue
      reg = "#{param(:xmotex)}"
      if is_exact || is_regular || is_whole_word
        reg = {content: reg, exact:is_exact, whole_word:is_whole_word, not_regular:!is_regular}
      else
        reg
      end
      @full_page.with_exergue( reg )
    end

    # Cette méthode est appelée lorsque l'on vient de l'atelier
    # icare (depuis un bureau)
    #
    # OBSOLÈTE : la collection est maintenant en accès libre.
    #
    def encart_icarien
      # Si l'user (icarien) est identifié, on n'a rien besoin de
      # mettre.

      return '' #if user.identified?

      # icarien_cpassword = param(:cpicare)
      # icarien_pseudo    = param(:picare)
      # icarien_id        = param(:idicare)
      # icarien_mail      = param(:micare)
      # icarien_salt      = ''
      # icarien_sexe      = param(:xicare)
      # # L'icarien existe-t-il ?
      # u = User.table_users.get(where: {mail: icarien_mail})
      # if u.nil?
      #   # L'icarien n'est pas connu
      #   # -------------------------
      #   # Puisqu'on ne peut passer par ici que lorsque l'icarien est
      #   # actif, on peut créer automatiquement l'icarien
      #   icarien_options = "00100000000000000000000000000001"
      #   icarien_data = {
      #     pseudo:     icarien_pseudo,
      #     patronyme:  icarien_pseudo,
      #     mail:       icarien_mail,
      #     cpassword:  icarien_cpassword,
      #     salt:       icarien_salt,
      #     options:    icarien_options,
      #     sexe:       icarien_sexe,
      #     created_at: NOW,
      #     updated_at: NOW
      #   }
      #   User.table_users.insert(icarien_data)
      # else
      #   # L'icarien est connu
      #   # --------------------
      #   # Noter que pour passer par ici, il faut qu'il y ait :fromicare à 1
      #   # dans l'URL et cette variable n'existe que si l'icarien est actif.
      # end
      # 'En tant qu’icarien actif, il suffit de vous identifier pour pouvoir consulter la page dans son intégralité.'.in_div(id: 'cadre_icarien', class: 'air cadre')
    end

    # Le message de page en cours d'écriture et pas encore
    # prête pour la lecture
    def message_niveau_developpement_insuffisant
      if user.authorized?
        mess_dev_insuffisant_authorized
      else
        mess_dev_insuffisant_non_authorized
      end
    end

    # Message en cas de niveau de développement de la page
    # insuffisant pour un utilisateur autorisé, c'est-à-dire un
    # abonné, un auteur du programme UN AN ou un icarien
    # actif.
    def mess_dev_insuffisant_authorized
      <<-HTML
<div class="red air">
  #{user.pseudo}, cette page est en cours de rédaction. Son niveau de développement est #{developpement}, vous pourrez la consulter à partir du niveau 8.
</div>
      HTML
    end

    # Message en cas de niveau de développement de la page
    # insuffisant pour un utilisateur non autorisé, c'est-à-dire
    # un simple inscrit ou un simple visiteur
    def mess_dev_insuffisant_non_authorized
      <<-HTML
<div class="red air">
  Cette page est en cours de rédaction et ne peut être consultée même partiellement.
</div>
      HTML
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
      ( lien_prev_page + lien_tdm + lien_next_page ).in_nav(class:"buttons #{where}")
    end

    def lien_tdm
      "Table des matières".in_a(href:"livre/#{livre_id}/tdm?in=cnarration").in_div(class:'nav lktdm')
    end
    def lien_prev_page
      href =
        if prev_page_id.nil?
          'javascript:void(0)'
        else
          "page/#{prev_page_id}/show?in=cnarration"
        end
      lien.backward_button( href: href, visible: !prev_page_id.nil?)
    end
    def lien_next_page
      href =
        if next_page_id.nil?
          'javascript:void(0)'
        else
          "page/#{next_page_id}/show?in=cnarration"
        end
      lien.forward_button(href: href, visible: !next_page_id.nil?)
    end

    # {StringHTML} Retourne le code HTML du bloc d'évaluation de
    # la page
    def bloc_evaluation
      user.authorized? || ( return '' )
      we = user.f_e.freeze
      menu_interet = [
        ["0", "endormi#{we}"],
        ["1", "ennuyé#{we}"],
        ["2", "peu intéressé#{we}"],
        ["3", "intéressé#{we}"],
        ["4", "très intéressé#{we}"],
        ["5", "passionné"]
      ].in_select(name:'evaluation[interet]', id:'evaluation_interet', selected: "3")
      menu_clarte = [
        ["0", "incompréhensible"],
        ["1", "difficile"],
        ["2", "peu claire"],
        ["3", "claire"],
        ["4", "très claire"],
        ["5", "limpide"]
      ].in_select(name:'evaluation[clarte]', id:'evaluation_clarte', selected:"3")

      (
        id.in_hidden(name:'evaluation[page_id]', id:'evaluation_page_id') +
        ( "Cette page vous semble #{menu_clarte}" ).in_div +
        ( "Elle vous a #{menu_interet}" ).in_div +
        ( "".in_textarea(name:'evaluation[comment]', placeholder:"Commentaire (au plus 500 signes)") ).in_div +
        ( "Soumettre cet avis".in_submit(id:'btn_submit_evaluation', class:'small btn') ).in_div(class:'right')
      ).in_div(id:'bloc_evaluation').in_div(class:'right').in_form( action:"page/evaluate?in=cnarration", id:"form_evaluation_page")

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
