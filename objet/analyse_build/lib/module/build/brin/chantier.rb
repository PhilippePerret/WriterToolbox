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
    suivi "** Construction des brins"
  rescue Exception => e
    debug e
    error "Erreur lors de la construction des brins : #{e.message}"
  else
    true # pour poursuivre
  end

  # ---------------------------------------------------------------------
  #   Méthodes de constructions de chaque brin
  # ---------------------------------------------------------------------

  # On construit chaque brin en prenant simplement la scène à laquelle
  # appartient le paragraphe (ou la scène).
  def build_brins_simples
    listing_simple_all_brins =
      brins_as_instances.collect do |brin|
        brin.as_simple_list
      end.join('')
    
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
