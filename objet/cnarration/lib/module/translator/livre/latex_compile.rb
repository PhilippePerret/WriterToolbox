# encoding: UTF-8
=begin

Méthode de compilation du fichier du livre vers PDF ou PostScript

=end
class Cnarration
class Livre

  # {Hash} contenant les options pour le suivi de la compilation
  # latex
  attr_reader :options_suivi_latex

  # Le dossier où doivent se trouver les scripts latex, biber et
  # compagnie.
  def texlive_folder
    "/usr/local/texlive/2015/bin/x86_64-darwin/"
  end

  # Méthode qui réceptionne le retour d'une compilation
  # en ligne de commande
  def suivre_exec command
    res = `#{texlive_folder}#{command} 2>&1`.force_encoding('utf-8')
    if verbose?
      debug "Commande exécutée : #{command}"
      debug "Résultat commande : #{res}"
    end
  end

  # = main =
  #
  # Méthode principale de compilation du livre
  # en latex ou ?
  # +options+
  #   :open_pdf     Si true, ouvre le PDF (true par défaut)
  #   :verbose      Si true, le suivi est affiché en sub_log
  #                 (false par défaut)
  def compile as = :latex, options = nil

    compile_default_options options

    # Il faut définir les paths avant de se déplacer dans le
    # dossier (ci-dessous) sinon ils seraient calculés par
    # rapport à ce dossier (expand_paths)
    maintex_full_path = latex_main_file.full_path
    maintex_affx_path = latex_main_file.affixe_path

    maintex_affixe = latex_main_file.affixe
    maintex_nfile  = latex_main_file.name

    # Il faut se placer dans le dossier pour pouvoir exécuter
    # les commandes de compilation
    Dir.chdir(latex_folder.to_s) do
      suivre_exec "latex #{maintex_nfile}"
      suivre_exec "biber #{maintex_nfile}"
      suivre_exec "latex #{maintex_nfile}"
      suivre_exec "makeindex -s ../commons/index_mef.ist #{maintex_affixe}.idx"
      suivre_exec "pdflatex #{maintex_nfile}"
      suivre_exec "pdflatex #{maintex_nfile}"
      suivre_exec "dvips #{maintex_affixe}.dvi"
    end

    if open_pdf?
      if pdf_main_file.exist?
        lien_open = lien.edit_file "#{pdf_main_file}", {editor: 'Preview', titre: "#{pdf_main_file}"}
        flash "L'ouverture du document #{lien_open} est demandée (cliquer sur le path ci-contre si le document ne s'ouvre pas)."
        `open \"#{pdf_main_file}\"`
      else
        error "Malheureusement, le fichier PDF n'a pas pu être construit. Consulter le fichier log."
      end
    end

    suivi << "    = Compilation latex OK"
  end

  # On règle les options par défaut avant la
  # compilation.
  def compile_default_options options
    options ||= Hash::new
    options[:open_pdf] = true unless options.has_key?(:open_pdf)
    @options_suivi_latex = options
    if verbose?
      suivi << "Options Cnarration::Livre pour la compilation : #{options.inspect}"
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes en fonction des options
  # ---------------------------------------------------------------------
  def open_pdf?
    @need_open_pdf ||= options_suivi_latex[:open_pdf]
  end
  def verbose?
    @is_verbose ||= options_suivi_latex[:verbose]
  end
end #/Livre
end #/Cnarration
