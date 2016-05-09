# encoding: UTF-8
=begin
Module principal de construction du manuel utilisateur

Note : À présent, on pourrait faire un module autonome de ce
module pour construire n'importe quel livre.

=end
require 'yaml'
site.require_module 'kramdown'

class SuperFile
  def corrections_latex
    code = self.read

    # Pour que les listes de définition s'affichent bien
    # c'est-à-dire avec la définition sous le mot
    # Car kramdown ne met pas de \hfill \\ donc la définition
    # se met au même niveau que le mot défini.
    code.gsub!(/\\item\[(.*?)\]/){
      "\\item[#{$1}] \\hfill \\\\\n"
    }

    self.write code
  end

end #/SuperFile

class Unan
class UManuel
class << self

  # Le dossier où doivent se trouver les scripts latex, biber et
  # compagnie.
  TEXLIVE_FOLDER = "/usr/local/texlive/2015/bin/x86_64-darwin/"

  # Le nom final du fichier PDF
  # Pour le régler :
  #   Unan::UManuel::pdf_name = "le-nom"
  attr_accessor :pdf_name

  # Soit true/false pour faire la version homme ou femme
  # du manuel ou :both pour sortir les deux versions d'un
  # seul coup.
  attr_accessor :version_femme

  # = main =
  #
  # Méthode principale de construction du manuel
  #
  def build


    # On indique aux méthodes de lien que la sortie doit
    # se faire en markdown (cela produira des liens que
    # kramdown saura interpréter et mettre en forme pour
    # LaTex)
    lien.output_format = :markdown

    # Au cas où il ne serait pas défini
    @pdf_name ||= "UAUS_Manuel"

    # Si ça n'est pas défini, on fait la version femme du
    # manuel
    # Pour la définir :
    #   Unan::UManuel::version_femme = true/false
    @version_femme = true if @version_femme === nil

    # On nettoie les fichiers auxiliaire du dossier LaTex pour
    # être sûr de repartir à zéro
    nettoie_fichiers_auxiliaires

    # On construit le fichier des assets inclus (un fichier
    # qui va charger tous les fichiers du dossier latex/assets)
    # dans le fichier principal
    build_file_inclusions_assets

    # On construit le fichier all_sources en transposant
    # tous les fichiers sources en LaTex
    build_all_sources_file

    # On définit les versions qu'il faut faire (version_femme)
    # La valeur de `version_femme` peut être :
    #   - true      => Sortir la version femme
    #   - false     => Sortir la version homme
    #   - :both     => Sortir les deux versions
    versions = if version_femme === true
      [true]
    elsif version_femme === false
      [false]
    else
      [true, false]
    end

    versions.each do |version|

      @version_femme = version

      # Pour forcer le renommage de ce fichier
      @manuel_pdf = nil

      # On détruit le fichier PDF s'il existe, pour être sûr
      # d'avoir une version fraiche
      manuel_pdf.remove if manuel_pdf.exist?

      # On définit le fichier de version sexuée pour
      # définir s'il faudra faire la version homme ou femme
      # du manuel
      build_file_definition_sexe_lecteur

      # On demande la compilation du fichier Latex
      compile_manuel_utilisateur

      if manuel_pdf_in_latex.exist?
        # On copie le PDF latex vers le dossier principal
        FileUtils::cp manuel_pdf_in_latex.to_s, manuel_pdf.to_s
        `open "#{manuel_pdf.to_s}"`
      else
        # Le fichier PDF n'existe pas, c'est qu'il y a eu un problème,
        # on affiche le fichier log en sortie standard
        STDOUT.write (folder_compilation + "_main_.log").read
        raise "Impossible de construire le PDF… Consulter le log"
      end

    end # /fin boucle sur chaque version (homme/femme/les deux)
  end

  # Commandes pour les inclusions des fichiers assets propre
  # au livre courant.
  # Ces fichiers se trouvent dans ./latex/assets
  # Noter que tous ces fichiers seront copiés dans le dossier
  # ./latex/compilation/assets pour ne pas ajouter de fichiers
  # auxiliaire ici et aussi pour que l'application puisse le
  # faire tout simplement (histoire de droits)
  def build_file_inclusions_assets
    p = folder_compilation+"assets/propres.tex"
    paux = folder_compilation+"assets/propres.aux"
    p.remove if p.exist?
    paux.remove if paux.exist?
    includes = Array::new
    Dir["#{folder_assets}/**/*.tex"].collect do |p|
      relpath = p.sub(/^#{Regexp::escape folder_assets.to_s}\//o,'')
      # On copie le fichier dans le dossier compilation/asset
      dest_path = folder_compilation+"assets/#{relpath}"
      dest_path.remove if dest_path.exist?
      FileUtils::cp p, dest_path.to_s
      # Si c'est la couverture, c'est plus tard qu'elle doit être
      # inclusion, quand on sera déjà dans le begin{document}
      next if File.basename(p) == "cover.tex"
      # Sinon, pour un autre fichier, on l'inclut
      relpath = relpath[0..-5]
      includes << "\\input{assets/#{relpath}}"
    end
    p.write includes.join("\n")
  end
  def build_file_definition_sexe_lecteur
    p = folder_compilation+"assets/define_version_sexuee.tex"
    p.write <<-TEX
% === Définition de la verion homme/femme ===
\\newboolean{pourfille}
\\setboolean{pourfille}{#{version_femme ? 'true' : 'false'}}
    TEX
  end

  def build_all_sources_file
    all_sources_file.remove if all_sources_file.exist?
    all_sources_file.append(<<-TEX)
% Update du fichier des sources #{Time.now}
%
% On doit inclure (input) tous les fichiers sources du manuel
% avant sa compilation.

% === Fichiers inclus ===


    TEX

    SuperFile::before_markdown_code = SuperFile::new(_("utils/definition_liens.md")).read

    # TODO: On doit commencer par un fichier définissant la
    # table des matières à utiliser

    # Les fichiers à traiter
    # Si un fichier table des matières existe, on le prend, sinon,
    # on prend tous les fichiers dans le dossier, dans leur ordre
    if tdm_file.exist?
      liste_files = Array::new
      # STDOUT.write YAML::load_file(tdm_file.to_s).inspect
      # return
      YAML::load_file(tdm_file.to_s).each do |dossier, affixe_list|
        affixe_list.each do |affixe|
          affixe += ".md" unless affixe.end_with?('md')
          liste_files << (folder_markdown + "#{dossier}/#{affixe}").to_s
        end
      end
    else
      liste_files = Dir["#{folder_markdown}/**/*.md"]
    end

    # ATTTENTION : SEULEMENT SI ON UTILISE LE SCRIPT DANS TEXTMATE
    # STDOUT.write liste_files.inspect

    liste_files.each do |pathmd|
      # On doit traiter le fichier et l'ajouter
      # à la liste des inputs

      # Chemin relatif
      # Noter qu'il servira aussi de path relatif de
      # l'affixe puisqu'on ajoute ".tex" au path complet (sans
      # retirer l'extension) pour obtenir le nom du fichier
      # latex.
      relpath = pathmd.sub(/^#{folder_markdown}\//o,'')
      # Nom du fichier Markdown (juste pour info)
      nfile   = File.basename(pathmd)
      # Le path du fichier Latex qu'on va fabriquer
      path_latex = folder_compilation + "sources/#{relpath}.tex"
      # Le dossier du fichier latex
      doslatex = File.expand_path(File.dirname(path_latex))
      # On crée la hiérarchie de dossier si nécessaire
      `mkdir -p "#{doslatex}"`
      # On transforme le fichier markdown en fichier latex
      sfile = SuperFile::new(pathmd)
      sfile.kramdown(output_format: :latex, in_file: path_latex)

      # On procède à quelques corrections latex finales (noter
      # que c'est le path du fichier LaTex qu'il faut donner)
      path_latex.corrections_latex

      all_sources_file.append("\\input{sources/#{relpath}}\n")
    end
  end

  # Nettoyage (donc suppression) des fichiers auxiliaires pour
  # être certain de repartir à zéro et de tout refaire
  def nettoie_fichiers_auxiliaires
    return if false == folder_latex.exist?
    Dir["#{folder_compilation}/**/*.aux"].each do |paux|
      File.unlink paux
    end
  end

  # Le fichier LaTex est prêt, on peut le compiler
  def compile_manuel_utilisateur
    Dir.chdir("#{folder_compilation}") do
      suivre_exec "latex _main_.tex"
      # suivre_exec "pdflatex _main_.tex"
      suivre_exec "biber _main_.tex"
      suivre_exec "latex _main_.tex"
      # suivre_exec "pdflatex _main_.tex"
      suivre_exec "makeindex _main_.idx"
      suivre_exec "pdflatex _main_.tex"
      suivre_exec "pdflatex _main_.tex"
      # suivre_exec "dvips _main_.dvi"
    end
  end

  # Méthode qui réceptionne le retour d'une compilation
  # en ligne de commande
  def suivre_exec command
    res = `#{TEXLIVE_FOLDER}#{command} 2>&1`.force_encoding('utf-8')
    debug "Commande exécutée : #{command}"
    debug "Résultat commande : #{res}"
  end

  # ---------------------------------------------------------------------
  #   Méthodes de path
  # ---------------------------------------------------------------------
  def affixe
    @affixe ||= "_main_"
  end
  # Le fichier qui rassemble toutes les sources (c'est celui-là qu'il
  # faut updater chaque fois)
  def all_sources_file
    @all_sources_file ||= folder_compilation + "all_sources.tex"
  end
  def manuel_pdf
    @manuel_pdf ||= folder + "#{pdf_name}_v#{version_femme ? 'F' : 'H'}.pdf"
  end
  def manuel_pdf_in_latex
    @manuel_pdf_in_latex ||= folder_compilation + "_main_.pdf"
  end
  def manuel_latex
    @manuel_latex ||= folder_compilation + "#{affixe}.tex"
  end
  def folder_markdown
    @folder_markdown ||= folder + "sources_md"
  end
  def folder_assets_compilation
    @folder_assets_compilation ||= folder_compilation+"assets"
  end
  def folder_assets
    @folder_assets ||= folder+"assets_latex"
  end
  def folder_compilation
    @folder_compilation ||= folder_latex+"compilation"
  end
  def folder_latex
    @folder_latex ||= folder + "latex"
  end
  # {SuperFile} Table des matières
  # Le fichier peut s'appeler tdm.yaml, _tdm_.yaml ou avec des
  # capitales et se trouver soit à la racine du dossier du
  # livre à construire soit dans le dossier des sources markdown
  def tdm_file
    @tdm_file ||= begin
      p = nil
      ["tdm", "TDM", "_tdm_", "_TDM_"].each do |affixe|
        [folder, folder_markdown].each do |dossier|
          p = dossier + "#{affixe}.yaml"
          break if p.exist?
        end
      end
      p
    end
  end
  def folder
    @folder ||= site.folder_objet + "unan/aide/manuel"
  end

end #/<< self
end #/UManuel
end #/Unan
