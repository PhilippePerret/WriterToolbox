# encoding: UTF-8
site.require_deeper_gem "kramdown-1.9.0"
class Cnarration
class Livre

  # Extension de Cnarration::Livre
  # Méthodes spéciales pour l'export latex ajoutées à la
  # class Cnarration::Livre

  # = main =
  #
  # Méthode principale procédant à l'export vers Latex du livre
  # Cette méthode est appelée par le fichier _main_.rb
  #
  def export_latex

    suivi << "*** Export vers latex du livre “#{data[:hname]}”"

    # Créer un dossier principal pour le livre (:folder)
    # C'est dans ce dossier que se trouvera l'intégralité des
    # élément du livre LaTex
    init_latex_folder

    # Créer un dossier pour les _sources (toutes au même niveau)
    latex_source_folder.build

    # Créer un fichier principal Latex et le préparer
    # à intégrer toutes les sources
    latex_main_file.init


    # On prépare une table qui va contenir tous les
    # titres et tous les handlers de fichiers pour
    # les inclure (source) ou les écrire (titres) dans
    # le fichier latex principal
    @liste_inclusions = Array::new

    # Passer en revue toutes les sources (tous les fichiers) et
    # les traiter.
    sources.each { |source| traite_source source }

    # Prendre la table des matières du livre et créer les titres
    # et les inclusions dans le fichier principal LaTex
    @liste_inclusions.each_with_index do |chose, index|
      if chose.nil?
        # => titre ou erreur
      else
        # => handler
        latex_main_file.write "\\include{sources/#{chose}}"
      end
    end

    # On peut terminer le fichier latex principal du
    # livre
    # Noter qu'il reste ouvert en écriture (ilivre.latex_main_file.write)
    # et que le fermer consiste juste à "ender" le document.
    latex_main_file.close

    suivi << "  = Export du livre “#{data[:hname]}” OK"

  end

  def suivi
    @suivi ||= Cnarration::suivi
  end

  # = main =
  #
  # Méthode principale pour traiter la source +psrc+ qui est
  # le path du fichier Markdown/kramdown
  def traite_source src_path

    # === Définition des données du fichier source ===
    src_path = SuperFile::new(src_path) unless src_path.instance_of?(SuperFile)
    # Chemin relatif au fichier
    src_relpath = src_path.to_s.sub(/^#{folder}\//,'')
    # handler du fichier (qui permettra d'en trouver l'ID)
    src_handler = src_relpath[0..-4]
    # ID du fichier source
    src_id = Cnarration::table_pages.select(where:"handler = '#{src_handler}' AND livre_id = #{id}").keys.first
    raise "Impossible d'obtenir l'ID de la page source de path : #{src_path} (avec le handler '#{src_handler}')" if src_id.nil?
    # Index du fichier dans la table des matières
    src_index = tdm.pages_ids.index(src_id)
    # On ajoute ce fichier à la liste suivant son index
    @liste_inclusions[src_index] = src_handler

    suivi << "* Traitement de #{src_handler} (index: #{src_index})"

    # === Création du fichier source ===

    # Le fichier latex final
    src_dest = latex_source_folder+"#{src_handler}.tex"
    src_dest.folder.build unless src_dest.folder.exist?

    # Traitement par latex
    src_dest.write Kramdown::Document.new(src_path.read).send(:to_latex)

  end

  # Toutes les sources du livre
  def sources
    @sources ||= begin
      Dir["#{folder}/**/*.md"]
    end
  end
  # {Cnarration::LatexMainFile} Instance du fichier main latex
  def latex_main_file
    @latex_main_file ||= begin
      Cnarration::LatexMainFile::new(self)
    end
  end

  # Préparation du dossier Latex principal dans les
  # dossiers temporaires.
  # On copie dans ce dossier tous les éléments du dossier
  # assets qui seront utiles à tous les livres.
  def init_latex_folder
    latex_folder.build
    fassets = Cnarration::folder+"lib/module/latex/assets/."
    FileUtils::cp_r fassets.to_s, "#{latex_folder.folder}/"
    # Il faut détruire le fichier READ_ME qui sert pour le
    # dossier asset mais pas pour les livres exportés
    (latex_folder.folder+'_read_me_.md').remove
  end

  def latex_source_folder
    @latex_source_folder ||= begin
      d = latex_folder+'sources'
      d.remove if d.exist?
      d
    end
  end
  def latex_folder
    @latex_folder ||= tmp_latex_folder+"BOOK_#{folder_name.upcase}"
  end
  def tmp_latex_folder
    @tmp_latex_folder ||= begin
      d = site.folder_tmp+"latex"
      d.remove if d.exist?
      d
    end
  end

end #/Livre
end #/Cnarration
