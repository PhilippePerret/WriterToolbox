# encoding: UTF-8
=begin

Méthode de compilation du fichier du livre vers PDF ou PostScript

=end
class Cnarration
class Livre

  # Le dossier où doivent se trouver les scripts latex, biber et
  # compagnie.
  def texlive_folder
    "/usr/local/texlive/2015/bin/x86_64-darwin/"
  end

  # Méthode qui réceptionne le retour d'une compilation
  # en ligne de commande
  def suivre_exec command
    debug "Commande exécutée : #{command}"
    suivi << `#{texlive_folder}#{command} 2>&1`.force_encoding('utf-8')
  end

  # = main =
  #
  # Méthode principale de compilation du livre
  # en latex ou ?
  # +options+
  #   :open_pdf     Si true, ouvre le PDF (true par défaut)
  def compile as = :latex, options = nil

    options = compile_default_options options

    # # Pour fonctionner avec un fichier bash contenant
    # # toutes les commandes
    # bash_file.write compilation_code
    # File.chmod(0777, bash_file.path)
    # Dir.chdir(latex_folder.to_s) do
    #   debug "On se trouve dans : #{File.expand_path('.')}"
    #   suivi << `./bash_script.sh 2>&1`
    # end

    # Il faut définir les paths avant de se déplacer dans le
    # dossier (ci-dessous) sinon ils seraient calculés par
    # rapport à ce dossier (expand_paths)
    maintex_full_path = latex_main_file.full_path
    maintex_affx_path = latex_main_file.affixe_path

    # Il faut se placer dans le dossier pour pouvoir exécuter
    # les commandes de compilation
    Dir.chdir(latex_folder.to_s) do
      suivre_exec "latex \"#{maintex_full_path}\""
      suivre_exec "biber \"#{maintex_affx_path}\""
      suivre_exec "latex \"#{maintex_full_path}\""
      suivre_exec "makeindex \"#{maintex_affx_path}\""
      suivre_exec "pdflatex \"#{maintex_full_path}\""
      suivre_exec "dvips \"#{maintex_affx_path}.dvi\""
    end
    "open -a Preview \"#{maintex_affx_path}.pdf\"" if options[:open_pdf]
    suivi << "    = Compilation latex OK"
  end

#   def bash_file
#     @bash_file ||= latex_folder + "bash_script.sh"
#   end
#   def compilation_code
#     <<-CODE
# #!/bin/bash
#
# #{texlive_folder}latex \"#{latex_main_file.full_path}\"
# #{texlive_folder}biber \"#{latex_main_file.affixe_path}\"
# #{texlive_folder}latex \"#{latex_main_file.full_path}\"
# #{texlive_folder}makeindex \"#{latex_main_file.affixe_path}\"
# #{texlive_folder}pdflatex \"#{latex_main_file.full_path}\"
# open \"#{latex_main_file.affixe_path}.pdf\"
#     CODE
#   end

  def compile_default_options options
    options ||= Hash::new
    options[:open_pdf] = true unless options.has_key?(:open_pdf)
    return options
  end

end #/Livre
end #/Cnarration
