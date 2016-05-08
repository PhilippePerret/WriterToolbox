# encoding: UTF-8
=begin
Module principal de construction du manuel utilisateur
=end
require 'yaml'
site.require_module 'kramdown'

class SuperFile
  def corrections_latex
    code = self.read

    # Pour que les listes de définition s'affichent bien
    # c'est-à-dire avec la définition sous le mot
    code.gsub!(/\\item\[(.*?)\]/){
      "\\item[#{$1}] \\hfill \\\\\n"
    }

    self.write code
  end

end #/SuperFile

class Unan
class UManuel
class << self

  # = main =
  #
  # Méthode principale de construction du manuel
  #
  def build

    # On nettoie les fichiers auxiliaire du dossier LaTex pour
    # être sûr de repartir à zéro
    nettoie_fichiers_auxiliaires

    # On détruit le fichier PDF s'il existe, pour être sûr
    # d'avoir une nouvelle version
    manuel_pdf.remove if manuel_pdf.exist?

    # On construit le fichier all_sources
    build_all_sources_file

    # On demande la compilation du fichier Latex
    compile_manuel_utilisateur

    if manuel_pdf_in_latex.exist?
      # On copie le PDF latex vers le dossier principal
      FileUtils::cp manuel_pdf_in_latex.to_s, manuel_pdf.to_s
      `open "#{manuel_pdf.to_s}"`
    else
      # Le fichier PDF n'existe pas, c'est qu'il y a eu un problème,
      # on affiche le fichier log
      STDOUT.write (folder_latex + "#{affixe}.log").read
      raise "Impossible de construire le PDF… Consulter le log"
    end

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
    liste_files = if tdm_file.exist?
      YAML::load_file(tdm_file.to_s).collect do |affixe|
        affixe += ".md" unless affixe.end_with?('md')
        (folder_markdown + affixe).to_s
      end
    else
      Dir["#{folder_markdown}/**/*.md"]
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
      path_latex = folder_latex + "sources/#{relpath}.tex"
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
    Dir["#{folder_latex}/**/*.aux"].each do |paux|
      File.unlink paux
    end
  end

  # Le fichier LaTex est prêt, on peut le compiler
  def compile_manuel_utilisateur
    maintex_affixe  = "UAUS_Manuel_auteur"
    Dir.chdir("#{folder_latex}") do
      suivre_exec "latex #{maintex_affixe}.tex"
      suivre_exec "biber #{maintex_affixe}.tex"
      suivre_exec "latex #{maintex_affixe}.tex"
      suivre_exec "makeindex #{maintex_affixe}.idx"
      suivre_exec "pdflatex #{maintex_affixe}.tex"
      suivre_exec "pdflatex #{maintex_affixe}.tex"
      # suivre_exec "dvips #{maintex_affixe}.dvi"
    end
  end

  # Méthode qui réceptionne le retour d'une compilation
  # en ligne de commande
  def suivre_exec command
    res = `#{texlive_folder}#{command} 2>&1`.force_encoding('utf-8')
    debug "Commande exécutée : #{command}"
    debug "Résultat commande : #{res}"
  end
  # Le dossier où doivent se trouver les scripts latex, biber et
  # compagnie.
  def texlive_folder
    "/usr/local/texlive/2015/bin/x86_64-darwin/"
  end

  # ---------------------------------------------------------------------
  #   Méthodes de path
  # ---------------------------------------------------------------------
  def affixe
    @affixe ||= "UAUS_Manuel_auteur"
  end
  # Le fichier qui rassemble toutes les sources (c'est celui-là qu'il
  # faut updater chaque fois)
  def all_sources_file
    @all_sources_file ||= folder_latex + "all_sources.tex"
  end
  def manuel_pdf
    @manuel_pdf ||= folder + "#{affixe}.pdf"
  end
  def manuel_pdf_in_latex
    @manuel_pdf_in_latex ||= folder_latex + "#{affixe}.pdf"
  end
  def manuel_latex
    @manuel_latex ||= folder_latex + "#{affixe}.tex"
  end
  def folder_markdown
    @folder_markdown ||= folder + "sources_md"
  end
  def folder_latex
    @folder_latex ||= folder + "latex"
  end
  # {SuperFile} Table des matières
  # Le fichier peut s'appeler tdm.yaml, _tdm_.yaml ou avec des
  # capitales.
  def tdm_file
    @tdm_file ||= begin
      p = nil
      ["tdm", "TDM", "_tdm_", "_TDM_"].each do |affixe|
        p = folder + "#{affixe}.yaml"
        break if p.exist?
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
