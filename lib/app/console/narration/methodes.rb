# encoding: UTF-8
=begin

Extension des commandes console pour la collection narration

Pour pouvoir les utiliser :

    console.load('narration')


=end
class SiteHtml
class Admin
class Console

  # Reçoit la référence à la page +page_ref+ et retourne un
  # Array dont les éléments sont des hash contenant :id, :titre
  # +page_ref+
  #   {Fixnum} ID de la page (mais en string ici)
  #   {String} Titre ou portion du titre. Si plusieurs pages sont
  #   trouvées, plusieurs hash de données sont retournés.
  # RETURN {Array de Hash} des pages ou NIL si aucune page.
  # Note : +page_ref+ est l'argument de fin de commande, la
  # plupart du temps.
  def pages_narration_from_page_ref page_ref
    site.require_objet 'cnarration'
    pages = if page_ref.numeric?
      hpage = Cnarration::table_pages.get(page_ref.to_i, colonnes:[:titre, :livre_id])
      [hpage]
    else
      Cnarration::table_pages.select(where:"titre LIKE '%#{page_ref}%'", colonnes:[:titre, :livre_id])
    end

    return pages unless pages.count == 0
    sub_log "Aucune page narration ne correspond à la référence `#{page_ref}`".in_span(class:'warning')
    return nil
  end

  def ouvrir_fichier_texte_page_narration page_ref
    pages = pages_narration_from_page_ref page_ref
    return "" if pages.nil?

    site.require_objet 'cnarration'
    if pages.count == 1
      ipage = Cnarration::Page::get(pages.first[:id])
      `open -a #{site.markdown_application} "#{ipage.fullpath}"`
    else
      sub_log(pages.collect do |hpage|
        ipage = Cnarration::Page::get(hpage[:id])
        hpage[:titre].in_a(target: :new,href:"site/open_file?path=#{CGI::escape ipage.fullpath}").in_li
      end.join.in_ul(class:'tdm'))
    end

    return ""
  end

  # Aller (afficher) la page narration de référence +page_ref+
  # +page_ref+
  #   {Fixnum} ID de la page (mais en string comme argument)
  #   {String} Une portion du titre
  # Note : Si c'est un fixnum, on affiche la page voulue
  #        Si c'est une portion de titre et qu'on trouve un seul titre,
  #        on affiche la page, sinon on affiche des liens pour les
  #        rejoindre.
  def aller_page_narration page_ref
    pages = pages_narration_from_page_ref page_ref
    return "" if pages.nil?
    if pages.count == 1
      redirect_to "page/#{pages.first[:id]}/show?in=cnarration"
    else
      sub_log(
        pages.collect do |hpage|
          hpage[:titre].in_a(href:"page/#{hpage[:id]}/show?in=cnarration").in_li
        end.join.in_ul(class:'tdm')
      )
    end
    return ""
  end

  # Commande exécutant la sortie latex de la collection
  def sortie_latex ref_book = nil
    ref_book = ref_book.nil_if_empty
    site.require_objet 'cnarration'
    Cnarration::require_module 'translator'
    Cnarration::exporter_collection_vers_latex ref_book
    return ""
  end

  # Commande complexe qui synchronise la base de données cnarration.db
  # en vérifiant le niveau de développement des pages pour garder les
  # modifications qui ont pu être faites online et offline.
  def run_synchronize_database_narration
    flash "Base de données Narration synchronisée."
    require './objet/cnarration/synchro.rb'
    SynchroNarration::synchronise_database_narration
    return ""
  end

  # RETURN La balise pour insérer une référence à
  # la page dans le document pour la page de référence
  # +page_ref+ qui est une portion du titre.
  def give_balise_of_page page_ref
    hpages = pages_narration_from_page_ref page_ref
    return if hpages.nil?
    balises = Array::new
    hpages.each do |pdata|
      pid = pdata[:id]
      balises << ["REF[#{pid}|#{pdata[:titre]}]", pid]
      balises << ["REF[#{pid}]", pid]
      balises << ["REF[#{pid}|ANCRE|#{pdata[:titre]}]", pid]
    end
    # Array retourné
    arr_balises = balises.collect do |balise, pid|
      {value:balise, after:"voir".in_a(href:"page/#{pid}/show?in=cnarration")}
    end
    flash "Trois sortes de balises ont été générées par page.<br>La première est la meilleure."
    return [arr_balises, ""]
  end

  # Méthode retournant la balise pour se rendre à la table
  # des matières du livre de référence +livre_ref+
  #
  # ATTENTION : Il peut s'agir ici soit d'un livre de la collection
  # Narration soit d'un livre de la bibliographie.
  #
  def give_balise_of_livre livre_ref
    site.require_objet 'cnarration'

    livre_ref = livre_ref.downcase

    suf_lien, livre_id = case livre_ref
    when /structure/  then ["la_structure", 1]
    when /personnage/ then ["les_personnages", 2]
    when /dynamique/  then ["la_dynamique_narrative", 3]
    when /(theme|thème|thematique)/ then ["la_thematique", 4]
    when /^documents?$/   then ["les_documents", 5]
    when /(travail|auteur)/   then ["le_travail_de_lauteur", 6]
    when /(procédé|procede)/  then ["les_procedes", 7]
    when /(concept|theorie)/  then ["les_concepts_narratifs", 8]
    when /dialogue/   then ["le_dialogue", 9]
    when /analyse/    then ["lanalyse_de_films", 10]
    else
      [nil, "Impossible de trouver le lien pour le livre de référence #{livre_ref}"]
    end

    # Livre introuvable
    # On va le rechercher dans la bibliographie
    if suf_lien.nil?
      liens_livres = liens_livres_bibliographie(livre_ref)
      if liens_livres.nil?
        return [nil, livre_id]
      else
        return [liens_livres, ""]
      end
    end

    # Lien inexistant
    unless Lien.instance.respond_to?("livre_#{suf_lien}".to_sym)
      return [nil, "`lien` ne répond pas à la méthode `livre_#{suf_lien}`, il y a un problème d'implémentation à régler avec la référence `#{livre_ref}`."]
    end

    lien_tdm = "Table des matières".in_a(href:"livre/#{livre_id}/tdm?in=cnarration")
    [[{value:"lien.livre_#{suf_lien}", after: lien_tdm}], ""]
  end


  # RETURN un {Array} des liens qui ont pu être trouvé dans la bibliographie
  # à partir de la référence +bref+ (pour "book référence") qui sera
  # recherché aussi bien dans l'identifiant, le titre que les auteurs
  def liens_livres_bibliographie bref
    require './objet/cnarration/lib/required/bibliographie.rb' unless defined?(Cnarration)
    founds = Array::new
    breg = /#{bref}/i
    Cnarration::BIBLIOGRAPHIE.each do |bid, bdata|
      if bid.match(breg) || bdata[:titre].match(breg) || bdata[:auteur].match(breg)
        founds << bdata
      end
    end
    return nil if founds.empty?
    # Sinon, on construit les liens et on les renvoie
    founds.collect do |bdata|
      {value: "LIVRE[#{bdata[:id]}|#{bdata[:titre]}]", after:nil}
    end
  end

  def give_balise_of_question question = nil
    question = "LA_QUESTION" if question.nil_if_empty.nil?
    [[{value:"CHECKUP[#{question}]"}], "Pour obtenir la balise pour écrire les questions, taper `balise checkup[ &lt;groupe&gt;]`"]
  end

  def give_balise_of_checkup groupe = nil
    groupe = groupe.nil_if_empty
    bal = if groupe.nil?
      "PRINT_CHECKUP"
    else
      "PRINT_CHECKUP[#{groupe}]"
    end
    [[{value:bal}], "Pour obtenir une balise question, taper `balise question[ &lt;la question&gt;]`"]
  end

  # Affiche (dans sub_log) les pages de la collection narration
  # qui sont des pages et dont le niveau de développement est
  # +nivdev+, de "1" à "a" en passant par "9"
  def liste_pages_narration_of_niveau nivdev
    site.require_objet 'cnarration'
    Cnarration::require_module 'cnarration' # par Cnarration::pages
    niveau_humain = Cnarration::NIVEAUX_DEVELOPPEMENT[nivdev.to_i][:hname]
    sub_log "Pages narration de niveau de développement #{nivdev} : #{niveau_humain}".in_h3
    sub_log Cnarration::pages_as_ul(where:"options LIKE '1#{nivdev}%'")
    return "" # pour ne rien afficher dans la console sous la ligne
  end

  def goto_nouvelle_page_narration
    redirect_to 'page/edit?in=cnarration'
    ""
  end

  def edit_page_narration page_ref
    pages = pages_narration_from_page_ref page_ref
    if pages.count == 1
      redirect_to "page/#{pages.first[:id]}/edit?in=cnarration"
    else
      propositions = pages.collect do |pdata|
        pid = pdata[:id]
        "#{pdata[:titre]} (livre ##{pdata[:livre_id]})".in_a(href:"page/#{pid}/edit?in=cnarration").in_li
      end.join.in_ul(class:'tdm')
      sub_log "Plusieurs pages de référence `#{page_ref}` ont été trouvées :".in_h3
      sub_log propositions
    end
    return ""
  end

  # Vérifie les pages physiques de narration qui ne se trouvent pas dans
  # la table.
  # Vérifie aussi que chaque enregistrement dans la table se trouve
  # bien dans une table des matières.
  # Produit le rapport complet et l'affiche dans le sub-log.
  def check_pages_narration_out_tdm
    site.require_objet 'cnarration'
    Cnarration::require_module 'admin/check_pages_out_tdm'
    sub_log Cnarration::Admin::check_pages_out_tdm
    return ""
  end


  # Affiche en sub-log une aide indiquant les données de tous les
  # livres, avec leur titre, leur ID et leur ID-symbolique
  # Ça répond à `aide|help livres narration`
  def aide_pour_les_livres_narration
    site.require_objet 'cnarration'
    str = Cnarration::LIVRES.collect do |bid, bdata|
      bid.to_s.rjust(2) + " " +
      bdata[:hname].ljust(34) +
      bdata[:folder].rjust(20)
    end.join("\n").in_pre
    sub_log str
    ""
  end

end #/Console
end #/Admin
end #/SiteHtml
