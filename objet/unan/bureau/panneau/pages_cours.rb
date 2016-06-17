# encoding: UTF-8
raise_unless user.unanunscript?

Unan::require_module 'page_cours'

class Unan
class Bureau

  def reset_all
    debug "-> Je passe dans reset_all bureau dans page_cours.rb"
    ['current_pday', 'updages', 'new_pages_cours', 'pages_cours'].each do |k|
      instance_variable_set("@#{k}", nil)
    end
  end
  # {Array de User::UPage} Liste des instances User::UPage
  # des pages à lire. C'est la liste principale qui permettra
  # de dispatcher les pages entre les trois sections, la section
  # des nouvelles pages, la section des pages à lire
  # et la section des pages récemment lues.
  #
  # Attention, l'identifiant dans la variable :pages_ids est
  # celui du travail (work). C'est la propriété `item_id` du
  # travail absolu de ce travail (work) qui définit l'id de la
  # page de cours à lire.
  # D'autre part, une fois qu'on a l'identifiant de la page
  # absolu, il faut regarder le statut (status) du record dans
  # la table de l'auteur pour voir si c'est une page à marquer
  # lue ou à marquer vue.
  def upages
    @upages ||= begin
      good_list_ids = Array::new() # pour correction éventuelle
      curr_list = current_pday.undone(:page)
      curr_list_ids = curr_list.collect{|h| h[:id]}
      # debug "curr_list : #{curr_list.inspect}"
      pages = curr_list.compact.collect do |wdata|
        absw_id = wdata[:id]
        item_id = wdata[:item_id]
        debug "absw_id = #{absw_id.inspect}/ item_id = #{item_id.inspect}"
        # work = user.program.work(awid)
        next if absw_id == nil  # problème
        next if item_id == nil  # problème
        good_list_ids << absw_id
        upage = User::UPage::new(user, item_id)
        upage
      end
      # Corriger les problèmes si on en trouve
      if good_list_ids != curr_list_ids
        debug "### La liste des :pages_ids a dû être corrigée"
        debug "ORIGINALE (seulement ids) : #{curr_list_ids.join(', ')}"
        debug "CORRIGÉE  (seulement ids) : #{good_list_ids.join(', ')}"
      end
      # Finalement, on donne la liste des instances de pages
      pages
    end
  end

  # {Array de User::UPage} Retourne une liste d'instances des pages de
  # cours à lire
  def new_pages_cours
    @new_pages_cours ||= begin
      upages.select do |upage|
        if upage.nil?
          raise "Une page est nil dans `new_pages_cours`" if OFFLINE
          false
        else
          upage.not_vue?
        end
      end
    end
  end

  # Les pages qui ont été vues mais pas encore marquées lues
  def pages_cours
    @pages_cours ||= begin
      upages.select do |upage|
        if upage.nil?
          raise "Une page est nil dans `pages_cours`" if OFFLINE
          false
        else
          upage.vue? && upage.not_lue?
        end
      end
    end
  end

  # Les dernières pages lues (ou relues)
  def last_pages_cours
    @last_pages_cours ||= begin
      where = "status & #{User::UPage::BIT_LUE} AND updated_at > #{NOW - 4.days}"
      user.table_pages_cours.select(where: where, colonnes:[:id]).collect do |hpc|
        User::UPage::get(user, hpc[:id])
      end
    end
  end


  # Cf. l'explication dans home.rb
  def missing_data
    @missing_data ||= begin
      # TODO Indiquer avec cette méthode quand des pages auraient dû être lues,
      # ou marquées lues et que la date a été dépassée.
      nil # pour le moment
    end
  end

end #/Bureau
end #/Unan


class User
class UPage

  # Affichage de la page de cours pour le bureau. C'est juste un
  # résumé de la page, avec un lien pour la voir entièrement et
  # des boutons pour la marquer vue, lue et terminée.
  def output_bureau
    (
      titre_page      +
      resume_page     +
      boutons_page
    ).in_div(class:'work page')
  end

  def infos_if_admin
    return "" unless user.admin? || OFFLINE
    "Page ##{id}".in_span(class:'tiny', style:'margin-right:1em')
    # TODO: Plus tard, un lien pour éditer les données et le texte
  end

  def titre_page
    (
      (
        infos_if_admin +
        "#{lien_read}"
      ).in_div(class:'fright') +
      page_cours.titre
    ).in_div(class:'titre')
  end

  # Description de la page
  # Noter qu'il s'agit de la description enregistrée dans les
  # données absolues de la page.
  def resume_page
    (
      page_cours.description
    ).in_div(class:'description')
  end

  # Lien pour lire la page dans
  def lien_read
    return "" unless vue?
    " Lire la page ".in_a(href:"page_cours/#{id}/show?in=unan", class:'inwork', target:'_page_cours_')
  end


  def boutons_page
    # Suivant le status de la UPage, il faut présenter un bouton différent
    lien_marquer_page = if not_vue? # <= toute nouvelle page
      title = "Marquer cette page comme vue (elle restera à marquer lue quand vous l'aurez consultée entièrement)"
      "Démarrer cette lecture".in_a(class:'warning', title:title, href:"#{bureau.route_to_this}&pid=#{id}&op=markvue")
    elsif not_lue? # <= page déjà prise en compte, mais pas encore lu deux fois
      title = "Marquer cette page comme lue"
      "Marquer la page lue".in_a(title:title, href:"#{bureau.route_to_this}&pid=#{id}&op=marklue")
    else
      title = "Remettre la page à lire ci-dessus."
      "Remettre à lire".in_a(title:title, href:"#{bureau.route_to_this}&pid=#{id}&op=unmarklue")
    end

    title = "Ajouter cette page de cours à votre table des matières personnelle"
    lien_to_tdm_perso = "Ajouter à TdM perso".in_a(title: title, href:"#{bureau.route_to_this}&pid=#{id}&op=addtdmperso")

    (
      lien_to_tdm_perso +
      lien_marquer_page
    ).in_div(class:'buttons')
  end

end #/UPage
end #/User

upage = User::UPage::get(user, param(:pid).to_i) unless param(:pid).nil?
case param(:op)
when 'markvue'
  upage.set_vue
  bureau.reset_all
  flash "Page marquée vue, vous pouvez à présent la lire."
when 'marklue'
  upage.marquer_lue
when 'unmarklue'
  upage.remarquer_a_lire
when 'addtdmperso'
  upage.set_in_tdm
  flash "Cette page a été ajoutée à votre table des matières personnelle."
end
