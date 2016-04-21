# encoding: UTF-8
class Cnarration
class << self

  # {Array} Pour le suivi des opérations
  attr_reader :suivi

  # = main =
  #
  # Méthode principale exportant la collection Narration vers
  # des fichiers LaTex pour impression final du livre.
  #
  def exporter_collection_vers_latex ref_book = nil
    @suivi    = Array::new
    @ref_book = ref_book

    @suivi << "Référence du livre : #{ref_book.nil? ? 'aucune' : ref_book}"

    # Créer un dossier principal pour le livre (:folder)
    # C'est dans ce dossier que se trouvera l'intégralité des
    # élément du livre LaTex
    Cnarration::Latex::init_latex_folder

    # Il faut dire à la méthode `lien` que tous les liens
    # doivent être donnés pour LaTex
    lien.output_format = :latex

    # -----------------------------------
    # Export de tous les livres à traiter
    # -----------------------------------
    livres_a_traiter.each do |livre_id|
      Livre::new(livre_id).export_latex
    end

    if defined?(console)
      console.sub_log @suivi.join("\n").force_encoding('utf-8').in_pre(class:'small')
    else
      debug @suivi.join("\n")
    end
    flash "Export vers Latex terminé avec succès"

    # Remettre l'ancien format des fois qu'une page
    # devrait être tout de suite affichée
    lien.output_format = nil

  rescue Exception => e
    debug e
    error e.message
  end

  # Retourne la liste des IDs de livres de la collection
  # à exporter vers latex. Pour le moment : soit un seul
  # livre, soit tous.
  def livres_a_traiter
    @livres_a_traiter ||= begin
      lat = Array::new
      op_titre = unless @ref_book.nil?
        livre_id = case true
        when @ref_book.numeric? then @ref_book.to_i
        else
          Cnarration::SYM2ID[@ref_book.to_sym]
        end
        raise "Aucun livre ne correspond à la référence #{@ref_book}…" if livre_id.nil?
        lat = [livre_id]
        livre_data = Cnarration::LIVRES[livre_id]
        "du livre #{livre_data[:hname]}"
      else
        lat = Cnarration::LIVRES.keys
        "de tous les livres"
      end
      @suivi << "Export LaTex #{op_titre}."
      debug "Livres à traiter : #{lat .inspect}"
      lat
    end
  end

end #/<< self

end #/Cnarration
