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

    # ========== CORE =============

    # Pour passer les pages progressivement (une à une), afin de
    # corriger les erreurs au fur et à mesure.
    # Mettre à 1000 pour les passer toutes
    max_sources = 30

    # Passer en revue toutes les sources (tous les fichiers) et
    # les traiter.
    sources.each do |source|

      itranslator = Cnarration::Translator::new self, source

      # Méthode qui traite le fichier en profondeur. Si la
      # méthode réussit, on poursuit en enregistrant le
      # handler pour l'inclure dans le fichier
      next unless itranslator.translate(:latex)
      # Pour ne laisser passer qu'un certain nombre de fichiers
      max_sources -= 1
      # On ajoute ce fichier à la liste des includes qu'il
      # faudra faire dans le fichier principal LaTex, en fonction
      # de l'index de la page
      @liste_inclusions[itranslator.tdm_index] = itranslator.handler

      break if max_sources < 1
    end

    # ========== /CORE =============

    # Prendre la table des matières du livre et créer les titres
    # et les inclusions dans le fichier principal LaTex
    @liste_inclusions.each_with_index do |chose, index|
      if chose.nil?
        # => titre ou erreur
        pid = tdm.pages_ids[index]
        hpage = Cnarration::table_pages.get(pid, colonnes:[:titre, :options])
        ischapter = hpage[:options][0] == "3"
        titre = hpage[:titre].gsub(/ /, '~{}')
        subdiv = ['', 'subsection', 'section','chapter'][hpage[:options][0].to_i]
        latex_main_file.write "\\#{subdiv}{#{titre}}"
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

    # On peut maintenant produire le fichier PDF ou autre
    compile :latex


  end

  def suivi
    @suivi ||= Cnarration::suivi
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

  # {SuperFile} du fichier PDF final qui doit être produit
  def pdf_main_file
    @pdf_main_file ||= SuperFile::new("#{latex_main_file.affixe_path}.pdf")
  end

  # Préparation du dossier Latex principal dans les
  # dossiers temporaires.
  # On copie dans ce dossier tous les éléments du dossier
  # assets qui seront utiles à tous les livres.
  def init_latex_folder
    latex_folder.build
    fassets = Cnarration::Translator::folder + "assets"
    FileUtils::cp_r "#{fassets.to_s}/.", "#{latex_folder.folder}/"
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
