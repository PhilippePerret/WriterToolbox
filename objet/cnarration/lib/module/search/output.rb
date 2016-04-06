# encoding: UTF-8
class Cnarration
class Search

  # = main =
  #
  # Code complet affiché en guise de résultat de recherche
  def output
    o = String::new
    o << "<hr>"
    o << result[:summary]
    o << div_informations_numeraires
    o << build_output
    return o.in_section(id:"search_resultat")
  end

  # ---------------------------------------------------------------------
  #   Méthodes de construction
  # ---------------------------------------------------------------------

  # Méthode qui construit et retourne le code HTML du div
  # contenant toutes les informations numéraires comme le
  # nombre de résultats trouvés, la durée de la recherche,
  # etc.
  def div_informations_numeraires
    div = Array::new
    # Nombres d'occurrencces
    nbf = result[:nombre_founds]
    s   = nbf > 1 ? 's' : ''
    str_ocs = "#{nbf} occurrence#{s} trouvée#{s}".in_span(id:'nombre_occurrences')
    if in_titres? && in_textes?
      str_ocs << " (titres : #{result[:nombre_in_titres] || 0}, pages : #{result[:nombre_in_textes] || 0})"
    end
    div << str_ocs
    # Durée de la recherche
    div << "en #{result[:duration].round(5)}secs"
    # Nombre de fichiers ou titres checkés
    unite = case true
    when in_titres? && in_textes? then "pages/titres"
    when in_titres?               then "titres"
    when in_textes?               then "pages"
    end
    div << "dans #{result[:nombre_searched]} #{unite}"

    div.join(", ").in_div(id:'search_infos_num')

  end
  # Méthode qui construit le texte pour les recherches
  # dans les fichiers
  # RETURN {StringHTML} Le texte à afficher
  # NOTES
  #   * La méthode n'est appelée que si on doit faire une
  #     recherche sur les textes.
  def build_output
    result[:by_file].sort_by{ |fid, gfile| - gfile.weight }.collect do |fid, gfile|
      gfile.output
    end.join.in_ul(class:'tdm')
  end

  # Résumé humain de la recherche
  def human_search_summary
    @human_search_summary ||= begin
      t = String::new
      t << "Rechercher "
      t << "exactement " if exact?
      t << "“#{searched}”".in_span(class:'bold')
      where = Array::new
      where << "les <span class='bold'>titres</span>" if in_titres?
      where << "les <span class='bold'>textes</span>" if in_textes?
      t << " dans #{where.pretty_join}"
      t << " sans se soucier de la casse" unless exact?
      t << " par expression régulière" if regular?
      t << "."
      t.in_div(class:'green small')
    end
  end

end #/Search
end #/Cnarration
