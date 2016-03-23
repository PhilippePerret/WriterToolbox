# encoding: UTF-8
=begin

Extension des commandes console pour la collection narration

Pour pouvoir les utiliser :

    console.load('narration')


=end
class SiteHtml
class Admin
class Console

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


end #/Console
end #/Admin
end #/SiteHtml
