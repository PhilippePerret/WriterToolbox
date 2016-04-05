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
    o << "durée de l'opération : #{result[:duration].round(5)}secs".in_div(class:'small right')
    o << build_output
    return o
  end

  # ---------------------------------------------------------------------
  #   Méthodes de construction
  # ---------------------------------------------------------------------

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

end #/Search
end #/Cnarration
