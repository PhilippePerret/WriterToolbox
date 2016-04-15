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

    livres_a_traiter.each do |livre_id|
      export_livre_vers_latex livre_id
    end

    if defined?(console)
      console.sub_log @suivi.join("<br>\n")
    else
      debug @suivi.join("\n")
    end
    flash "Export vers Latex terminé avec succès"
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

  # = main =
  #
  # Méthode principale pour l'export LaTex d'un livre
  # en fournissant son ID
  def export_livre_vers_latex livre_id
    @dbook = Cnarration::LIVRES[livre_id]

    ilivre = Livre::new(livre_id)

    # Créer un dossier principal pour le livre (:folder)
    # C'est dans ce dossier que se trouvera l'intégralité des
    # élément du livre LaTex
    ilivre.init_latex_folder

    # Créer un dossier pour les _sources (toutes au même niveau)
    ilivre.latex_source_folder.build

    # Créer un fichier principal Latex
    ilivre.latex_main_file.init

    # Faire toutes les pré-corrections du texte pour que Kramdonw
    # le transforme bien.

    # Transformer toutes les sources en fichiers LaTex (Kramdown)

    # Faire toutes les post-corrections du texte kramdowné
    # s'il en reste

    # Prendre la table des matières du livre et créer les titres
    # et les inclusions dans le fichier principal LaTex

    # On peut terminer le fichier latex principal du
    # livre
    # Noter qu'il reste ouvert en écriture (ilivre.latex_main_file.write)
    # et que le fermer consiste juste à "ender" le document.
    ilivre.latex_main_file.close

    @suivi << "*** Export vers latex du livre “#{@dbook[:hname]}”"
  end
end #/<< self

end #/Cnarration
