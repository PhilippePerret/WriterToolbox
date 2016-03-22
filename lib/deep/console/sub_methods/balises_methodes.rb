# encoding: UTF-8
=begin

Module qui contient les traitements des balises pour les textes ou les
fichier erb.

    balise <chose> <désignation chose>[ <format sortie>]

Exemples
--------

    balise livre documents erb
    # => "<%= lien.livre_les_documents %>"

    balise mot protag
    # => "MOT[8|protagoniste]" et autres mots contenant "protag"
    balise mot protag ERB
    # => "<%= MOT[8|protagoniste] %>" et autres mots contenant "protag"

=end
raise_unless_admin

class SiteHtml
class Admin
class Console

  # = main =
  #
  # Méthode principale de traitement des commandes commençant par
  # `balise <chose> etc.`. Produit des champs de saisie où on peut
  # récupérer le code fourni.
  #
  # +bdata+
  def main_traitement_balise bdata
    debug "bdata : #{bdata.inspect}"
    balises, message = case bdata[0]
    when 'film'   then give_balise_of_filmodico(bdata[1])
    when 'mot'    then give_balise_of_scenodico(bdata[1])
    when 'livre'  then give_balise_of_livre(bdata[1])
    end

    as = case bdata[2]
    when '', nil then nil
    else bdata[2].downcase
    end

    return message if balises.nil? # aucune trouvée

    sub_log( liste_built_balises(balises, as) + rappels_balises(as) )
    return ""
  end

  def rappels_balises as
    c = ""
    unless as == 'erb'
      c << ("Rappel : Vous pouvez utiliser `ERB` ou `erb` à la fin de la commande pour obtenir une balise ERB.").in_div(class:'tiny italic')
    end
    c
  end

  # Méthode qui reçoit la liste des balises et les affiche sous
  # la console (sub_log)
  # Chaque élément de {Array} +arr_balises+ doit contenir au
  # moins :value, la valeur à donner et peut contenir :
  # :after    Texte à écrire après le champ
  def liste_built_balises arr_balises, as
    arr_balises.collect do |hbalise|
      hbalise[:value] = "<%= #{hbalise[:value]} %>" if as == 'erb'
      c = "<input type='text' value='#{hbalise[:value]}' />"
      c << " #{hbalise[:after]}" unless hbalise[:after].nil?
      c.in_div
    end.join + '<script type="text/javascript">UI.auto_selection_text_fields()</script>'
  end

  # ---------------------------------------------------------------------
  #
  # ---------------------------------------------------------------------

  # Méthode qui retourne les balises pour le film désigné par
  # +fref+ qui peut être un titre tronqué, français, etc.
  def give_balise_of_filmodico fref
    site.require_objet 'filmodico'
    # On récolte les films qui peuvent correspondre au titre original,
    # au titre en français ou au film-id
    res = Filmodico::table_films.select(where:"titre LIKE '%#{fref}%' OR titre_fr LIKE '%#{fref}%' OR film_id LIKE '%#{fref}%'", colonnes:[:film_id, :titre], nocase:true).values

    if res.empty?
      [nil, "Aucun film ne correspond à la référence #{fref}"]
    else
       balises = res.collect do |hfilm|
        lien_fiche = hfilm[:titre].in_a(href:"filmodico/#{hfilm[:id]}/show", target:'_blank')
        {value: "FILM[#{hfilm[:film_id]}]", after: " (#{lien_fiche})"}
      end
      [balises, "Nombre de films trouvés : #{balises.count}"]
    end
  end

  def give_balise_of_scenodico mot_ref
    site.require_objet 'scenodico'
    res = Scenodico::table_mots.select(where:"mot LIKE '%#{mot_ref}%'", nocase: true, colonnes:[:mot]).values
    if res.empty?
      [nil, "Aucun mot n'a été trouvé correspondant à `#{mot_ref}`."]
    else
      balises = res.collect do |hmot|
        {value: "MOT[#{hmot[:id]}|#{hmot[:mot].downcase}]"}
      end
      [balises, "Nombre de mots trouvés : #{balises.count}"]
    end
  end

  def give_balise_of_livre livre_ref
    site.require_objet 'cnarration'

    livre_ref = livre_ref.downcase

    suf_lien, livre_id = case livre_ref
    when "structure", "la_structure" then ["la_structure", 1]
    when "personnages", "personnage", "les_personnages" then ["les_personnages", 2]
    when "dynamique", "dynamique_narrative", "la_dynamique_narrative", "elements_dynamiques" then ["la_dynamique_narrative", 3]
    when "themes", "les_themes", "thematique", "thématique", "la_thematique" then ["la_thematique", 4]
    when "documents", "les_documents", "document" then ["les_documents", 5]
    when "travail", "travail_auteur", "le_travail_de_lauteur" then ["le_travail_de_lauteur", 6]
    when "procédés", "procedes", "procedes_narratifs", "les_procedes", "les_procedes_narratif" then ["les_procedes", 7]
    when "concepts", "theorie", "théorie", "les_concepts", "concepts_narratifs" then ["les_concepts_narratifs", 8]
    when "dialogue", "le_dialogue" then ["le_dialogue", 9]
    when "analyse", "analyse_film", "les_analyses", "analyses_films" then ["lanalyse_de_films", 10]
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

end #/Console
end #/Admin
end #/SiteHtml
