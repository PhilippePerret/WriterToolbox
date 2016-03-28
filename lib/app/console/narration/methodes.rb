# encoding: UTF-8
=begin

Extension des commandes console pour la collection narration

Pour pouvoir les utiliser :

    console.load('narration')


=end
class SiteHtml
class Admin
class Console

  # Commande complexe qui synchronise la base de données cnarration.db
  # en vérifiant le niveau de développement des pages pour garder les
  # modifications qui ont pu être faites online et offline.
  def run_synchronize_database_narration
    flash "Base de données Narration synchronisée."
    require './objet/cnarration/synchro.rb'
    SynchroNarration::synchronise_database_narration
    return ""
  end

  # Méthode générale fonctionnelle permettant d'obtenir une
  # page en fonction de la référence donnée qui peut être
  # l'ID (nombre) de la page ou une portion de son titre.
  # Si plusieurs choix possibles, ils sont tous retournés
  # @RETURN : {Array} d'identifiant, même s'il n'y en a qu'un
  def pages_ids_from_page_ref page_ref
    if page_ref.numeric?
      return [page_ref.to_i]
    else
      site.require_objet 'cnarration'
      Cnarration::table_pages.select(where:"titre LIKE '%#{page_ref}%'", nocase: true, colonnes:[]).keys
    end
  end

  # Méthode retournant la balise pour se rendre à la table
  # des matières du livre de référence +livre_ref+
  def give_balise_of_livre livre_ref
    site.require_objet 'cnarration'

    livre_ref = livre_ref.downcase

    suf_lien, livre_id = case livre_ref
    when /structure/  then ["la_structure", 1]
    when /personnage/ then ["les_personnages", 2]
    when /dynamique/  then ["la_dynamique_narrative", 3]
    when /(theme|thème|thematique)/ then ["la_thematique", 4]
    when /document/   then ["les_documents", 5]
    when /(travail|auteur)/   then ["le_travail_de_lauteur", 6]
    when /(procédé|procede)/  then ["les_procedes", 7]
    when /(concept|theorie)/  then ["les_concepts_narratifs", 8]
    when /dialogue/   then ["le_dialogue", 9]
    when /analyse/    then ["lanalyse_de_films", 10]
    else
      [nil, "Impossible de trouver le lien pour le livre incconu #{livre_ref}"]
    end

    # Livre introuvable
    return [nil, livre_id] if suf_lien.nil?

    # Lien inexistant
    unless Lien.instance.respond_to?("livre_#{suf_lien}".to_sym)
      return [nil, "`lien` ne répond pas à la méthode `livre_#{suf_lien}`, il y a un problème d'implémentation à régler avec la référence `#{livre_ref}`."]
    end

    lien_tdm = "Table des matières".in_a(href:"livre/#{livre_id}/tdm?in=cnarration")
    [[{value:"lien.livre_#{suf_lien}", after: lien_tdm}], ""]
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
    pages_ids = pages_ids_from_page_ref page_ref
    debug "pages_ids: #{pages_ids.inspect}"
    if pages_ids.count == 1
      redirect_to "page/#{pages_ids.first}/edit?in=cnarration"
    else
      site.require_objet 'cnarration'
      hpages = Cnarration::table_pages.select(where:"id IN (#{pages_ids.join(', ')})", colonnes:[:titre, :livre_id])
      propositions = hpages.collect do |pid, pdata|
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
