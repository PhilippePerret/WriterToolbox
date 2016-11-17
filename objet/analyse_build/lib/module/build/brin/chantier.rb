# encoding: UTF-8
class AnalyseBuild

  # = main =
  #
  # Méthode principale de construction des brins
  #
  # La méthode n'est appelée que si des brins ont été collectés.
  #
  # RETURN true en cas de succès et false en cas d'échec
  #
  # PRODUIT
  #   Les fichiers de chaque brin. Plusieurs versions sont possibles.
  #
  def build_brins
    suivi "* Construction des brins"
    brins_html_file.exist? && brins_html_file.remove

    build_brins_simples

  rescue Exception => e
    debug e
    error "Erreur lors de la construction des brins : #{e.message}"
  else
    true # pour poursuivre
  end

  # ---------------------------------------------------------------------
  #   Méthodes de constructions de chaque brin
  # ---------------------------------------------------------------------

  # On construit chaque brin simplement, en prenant les paragraphes qui
  # appartiennent au brin ou le résumé de la scène si c'est toute la scène.
  # On l'enregistre dans un fichier.
  def build_brins_simples
    suivi "** Construction des brins simples"
    listing_simple_all_brins =
      brins_as_instances.collect do |brin|
        brin.as_simple_list
      end.join('')

    code =
      'Brins simples'.in_h3           +
      balise_styles('brins_simples')  +
      listing_simple_all_brins

    brins_html_file.append code
  end

  # ---------------------------------------------------------------------
  # Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def brins_as_instances
    @brins_as_instances ||= begin
      data_brins.collect do |bid, bdata|
        AnalyseBuild::Film::Brin.new(bdata)
      end
    end
  end

  def data_brins
    @data_brins ||= Marshal.load(brins_file.read)
  end

end #/AnalyseBuild
