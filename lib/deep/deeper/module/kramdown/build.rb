# encoding: UTF-8
=begin

Extension de la class SuperFile pour traiter un code markdown
avec Kramdown.

@usage

  site.require_module 'kramdown'

  <superfile>.kramdown[ <{options}>]

  # => Retourne le code transformé SAUF si :in_file est défini, qui
  # doit définir le path du fichier dans lequel écrire le code

=end

site.require_deeper_gem "kramdown-1.9.0"

class SuperFile

  DATA_OUTPUT_FORMAT = {
    :html   => {extension: '.html'},
    :latex  => {extension: ".tex" },
    :erb    => {extension: ".erb"}
  }

  # Retourne le code du fichier, kramdowné
  #
  # :alias: def as_kramdown
  def kramdown options = nil
    options ||= Hash::new

    options[:output_format] ||= :erb

    # La méthode de transformation, suivant le format
    # de sortie voulu
    mdown_method = case options[:output_format]
    when :html, :erb then :to_html
    when :latex      then :to_latex
    end

    # Pour extra_markdown par exemple
    output_format = case options[:output_format]
    when :html, :erb then :html
    when :latex      then :latex
    end

    # On lit le code du fichier en remplaçant les fins de
    # lignes windows par quelque chose de correct, au cas où
    code = self.read.gsub(/\r\n?/, "\n").chomp


    # Si le format de sortie est de l'ERB, il faut protéger les
    # balises ERB sinon, kramdown transformerait les pourcentages en
    # signe pourcentage.
    if options[:output_format] == :erb
      code = code.gsub(/<\%/,'ERBtag').gsub(/\%>/,'gatBRE')
    end

    # Si le code contient "\nDOC/" c'est que des documents sont
    # définis dans le code, on les traite avant tout autre
    # traitement
    code = code.mef_document if code.match(/\nDOC\//)

    # Si une méthode de traitement des images existe,
    # il faut l'appeler.
    # Noter qu'il faut appeler cette méthode AVANT la
    # suivante, car la suivante traite aussi les balises
    # IMAGE mais de façon plus générale (et sans pouvoir
    # définir des sous-dossiers).
    code = formate_balises_images_in(code) if self.respond_to?(:formate_balises_images_in)

    # Si une méthode formate_balises_propres existe, il
    # faut l'appeler sur le code pour les transformer
    code = code.formate_balises_propres if "".respond_to?(:formate_balises_propres)

    # Si une méthode de traitement additionnel existe,
    # il faut lui envoyer le code
    code = formatages_additionnels(code, options) if self.respond_to?(:formatages_additionnels)

    # Traitement extra kramdown
    # TODO: Dans l'idéal, il faudrait apprendre à les insérer
    # dans le traitement Kramdown::Document ci-dessous…
    code = ( code.extra_kramdown output_format )

    #
    # = MAIN TRAITEMENT MARKDOWN (KRAMDOWN) =
    #

    # debug "\n\ncode AVANT kramdown : #{code.gsub(/</,'&lt;').inspect} \n\n"

    # Pour une raison inconnue mais qui doit être propre à Kramdown,
    # les balises <personnages>...</personnages> en début de ligne
    # sont toujours agrémentées d'un <p> derrière après traitement par
    # kramdown.
    # Il faut donc, ci-dessous, "protéger" ces balises puis les
    # remettre après le kramdownage.
    # Note : J'ai essayé de changer les options de Kramdown mais ça
    # n'a rien changé. Dans l'idéal je pense qu'il ne faudrait pas
    # du tout de balise HTML avant de kramdowner.
    code.gsub!(/<personnage>(.+?)<\/personnage>/, 'PERStag\1gatSREP')

    # === KRAMDOWNAGE ===
    code_final = Kramdown::Document.new(code).send(mdown_method)

    # Déprotéger ce qui a été protégé avant Kramdown
    code_final.gsub!(/PERStag(.+?)gatSREP/,'<personnage>\1</personnage>')

    # debug "\n\ncode APRÈS kramdown : #{code_final.gsub(/</,'&lt;').inspect} \n\n"

    if code_final.match(/ERBtag/)
      if options[:output_format] == :erb
        code_final = code_final.gsub(/ERBtag/,'<%').gsub(/gatBRE/,'%>')
      else
        # Si la sortie n'est pas en :erb, il faut interpréter
        # le code
        code_final.gsub!(/ERBtag(.+?)gatBRE/){
          begin
            c = $1
            c = c[1..-1].string if c.start_with?('=')
            eval c
          rescue Exception => e
            debug e
            "[ERREUR EN INTERPRÉTANT `#{c}` : #{e.message}]"
          end
        }
      end
    end
    if options[:in_file]
      # Écrire le code dans ce fichier
      dest_path = case options[:in_file]
      when String     then options[:in_file]
      when TrueClass  then (self.folder + self.affixe).to_s
      end
      if File.extname(dest_path) == ""
        dest_path += DATA_OUTPUT_FORMAT[options[:output_format]][:extension]
      end
      SuperFile::new(dest_path).write code_final
    else
      # Retourner ce code
      return code_final
    end
  end
  alias :as_kramdown :kramdown


end
