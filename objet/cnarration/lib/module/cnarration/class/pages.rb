# encoding: UTF-8
=begin
Extension pour la gestion des pages de la collection narration
en temps qu'ensemble continu et homogène.
=end
class Cnarration
class << self

  # Retourne une donnée en fonction de params[:as] qui est
  # Array de data par défaut et retourne donc toutes les pages
  # dans l'ordre de création sous forme de array ou chaque élément
  # et un hash de donnée
  # param[:as]
  #   :array_data       Array de data (défaut)
  #   :array_instances  Array d'instances Cnarration::Page
  #   :hash_data        Hash de data (clé = id de la page)
  #   :hash_instances   Même chose avec des instances Cnarration::Page
  #   :ul               Comme une liste HTML dans UL
  #   :select           Comme un menu select avec en titre le titre de
  #                     la page et en valeur l'id
  #   :sorted           Si true, les pages sont classées par livre
  #                     et par table des matières
  #                     ATTENTION ! Si :sorted est true, la méthode
  #                     retourne toujours un hash avec en clé l'id
  #                     des livres et en valeur un hash contenant
  #                     :pages      Array des Hash de page CLASSÉES
  #                     :tdm        Liste des Ids de pages (tdm)
  #                     :livre      Instance Cnarration::Livre du livre
  # Ces pages peuvent être filtrées par le paramètre params[:where]
  # ce paramètre sera mis telle quelle dans le where du select pour
  # trouver les pages.
  def pages params = nil
    params ||= Hash::new
    params[:as] ||= :array_data
    params[:where] ||= "options LIKE '1%'"

    if [:array_instances, :hash_instances].include? params[:as]
      params[:colonnes] ||= []
    elsif params[:as] == :ul
      params[:colonnes] = [:titre]
    end

    params[:colonnes] << :livre_id if params[:sorted]

    data_requete = Hash::new
    data_requete.merge!( where: params.delete(:where) )
    data_requete.merge!( colonnes:params.delete(:colonnes) ) unless params[:colonnes].nil?
    # Si un ordre a été défini, il faut le prendre en compte
    data_requete.merge!(order: params.delete(:order)) unless params[:order].nil?

    pgs = table_pages.select(data_requete)

    # S'il faut classer les pages par livre et par table
    # des matières
    if params[:sorted]
      hsorted = Hash::new
      pgs.sort_by{|pid, pdata| pdata[:livre_id]}.each do |pid, pdata|
        livre_id = pdata[:livre_id]
        unless hsorted.has_key?(livre_id)
          # Un nouveau livre dont il faut prendre les informations
          ilivre = Cnarration::Livre::get(livre_id)
          livre_data = {
            pages:  Array::new,
            tdm:    ilivre.tdm.pages_ids,
            livre:  ilivre
          }
          hsorted.merge!(livre_id => livre_data)
        end

        # On ajoute cette page au livre, on ajoutant son index
        # dans la table des matières
        index_page = hsorted[livre_id][:tdm].index( pid )
        debug "Index de la page #{pdata[:titre]} : #{index_page}"
        pdata.merge!( numero: index_page)
        hsorted[livre_id][:pages] << pdata
      end

      # On classe les pages de chaque livre retenu
      hsorted.each do |livre_id, livre_data|
        hsorted[livre_id][:pages] = hsorted[livre_id][:pages].sort_by{|hpage| hpage[:numero]}
      end

      # ! C'est toujours ce hash qui est retourné !
      return hsorted
    end

    case params[:as]
    when :hash_data       then pgs
    when :array_data      then pgs.values
    when :array_instances then pgs.keys.collect{ |pid| Page::new(pid) }
    when :hash_instances
      h = Hash::new
      pgs.keys.each { |pid| h.merge!( pid => Page::new(pid) ) }
      h
    when :ul
      # Une liste UL doit être retournée
      pgs.values.collect do |hpage|
        hpage[:titre].in_option(value: hpage[:id])
      end.in_ul(class:'tdm')
    end
  end


  # Retourne le code HTML d'un UL contenant la liste des pages
  # répondant aux critères +options+
  # +options+ contient/définit
  #   :edition_buttons      Options pour les boutons d'édition.
  #                         Si nil, tous les boutons, sinon, mettre
  #                         :edit, :show, :text, :kill à true pour
  #                         ajouter le bouton correspondant.
  #   Tous les critères de `pages' ci-dessus, à commencer par la
  #   requête `where`
  def pages_as_ul options = nil
    options ||= Hash::new
    options_edit_btns = options.delete(:edition_buttons)
    options.merge!(as: :array_data)
    pages(options).collect do |hpage|
      (
        boutons_editions_for_page(hpage[:id], options_edit_btns) +
        hpage[:titre]
      ).in_li(class:'hover')
    end.join.in_ul(class:'tdm')
  end

  # Retourne le span flottant à droite des boutons d'édition pour
  # la page d'id +page_id+
  # +options+ permet de définir les boutons à afficher
  # Si nil, TOUS les boutons seront marqués
  #   :edit       Si true, le bouton pour éditer les data de la page
  #   :text       Si true, le bouton pour éditer le texte de la page
  #   :kill       Si true, le bouton pour détruire la page
  #   :show       Si true, le bouton pour afficher la page
  def boutons_editions_for_page page_id, options = nil
    bs = String::new
    if options.nil? || options[:edit]
      bs << "edit".in_a(class:'tiny', href:"page/#{page_id}/edit?in=cnarration", target:"_blank")
    end
    if options.nil? || options[:show]
      bs << "show".in_a(class:'tiny', href:"page/#{page_id}/show?in=cnarration", target:"_blank")
    end
    if user.manitou? && ( options.nil? || options[:text] )
      bs << lien.edit_file(Page::new(page_id).fullpath, titre: "texte", class:'tiny')
    end
    if user.manitou? && (options.nil? || options[:kill] )
      bs << "destroy".in_a(class:'tiny', href:"page/#{page_id}/destroy?in=cnarration")
    end
    bs.in_span(class:'btns fright')
  end

end #/<< self
end #/ Cnarration
