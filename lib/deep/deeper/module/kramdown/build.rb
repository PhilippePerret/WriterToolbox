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

class ::String
  DATA_OUTPUT_FORMAT = {
    :html   => {extension: '.html'},
    :latex  => {extension: ".tex" },
    :erb    => {extension: ".erb"}
  }

  # Kramdownise un string c'est-à-dire prend un code au format
  # markdown et le transforme en un autre code
  #
  # +options+
  #     :output_format:
  #         Format de sortie du code (HTML par défaut)
  #
  #     :owner    DONNÉE TRÈS IMPORTANTE qui détermine par exemple
  #               si le code vient d'un SuperFile. Dans ce cas, ce
  #               possesseur peut déterminer des méthodes supplémentaires
  #               de traitement
  #
  def kramdown options = nil

    options ||= Hash::new
    options[:output_format] = :html unless options.has_key?(:output_format)

    owner = options[:owner]

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

    code = self

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
    code = code.formate_balises_images(options[:folder_image]) if self.respond_to?(:formate_balises_images)

    # Si une méthode formate_balises_propres existe, il
    # faut l'appeler sur le code pour les transformer
    code = code.formate_balises_propres if self.respond_to?(:formate_balises_propres)

    # Si une méthode de traitement additionnel existe,
    # il faut lui envoyer le code
    if owner && owner.respond_to?(:formatages_additionnels)
      code = formatages_additionnels(code, options)
    end

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

    return code_final
  end

end

class SuperFile

  class << self

    # Pour ajouter au(x) fichier(s) traité(s) un code
    # markdown avant leur code.
    # Typiquement, ça peut servir par exemple pour définir
    # des liens "[texte]: mon/lien/cible"
    attr_accessor :before_markdown_code

  end #/ << self

  DATA_OUTPUT_FORMAT = {
    :html   => {extension: '.html'},
    :latex  => {extension: ".tex" },
    :erb    => {extension: ".erb"}
  }


  # Retourne le code du fichier, kramdowné
  #
  # :alias: def as_kramdown
  #
  # +options+
  #     Cf. la méthode String#kramdown ci-dessus
  #     + autres propriétés :
  #       :in_file    Si fourni, c'est un path dans lequel le code
  #                   transformé sera enregistré. Sinon, le code est
  #                   simplement retourné.
  #                   Ça peut être un SuperFile
  #
  def kramdown options = nil
    options ||= Hash::new

    # On doit produire un code ERB
    options[:output_format] ||= :erb
    options[:folder_image] = folder.to_s

    options.merge!(
      owner:        self,
      # Pour trouver un dossier image, if any
      folder_image: folder.to_s
    )

    code = self.read.gsub(/\r\n?/, "\n").chomp

    # Ajouter si nécessaire un code au code du
    # fichier (cf. ci-dessus)
    unless self.class::before_markdown_code.nil?
      code = self.class::before_markdown_code + "\n\n"+ code
    end

    # ATTENTION, ÇA NE FONCTIONNE QUE SI ON LANCE LE SCRIPT
    # TEXTMATE
    # STDOUT.write( code )

    code_final = code.kramdown(options)

    if options[:in_file]
      # Écrire le code dans ce fichier
      dest_path = case options[:in_file]
      when String, SuperFile then options[:in_file]
      when TrueClass  then (self.folder + self.affixe).to_s
      end
      if File.extname(dest_path.to_s) == ""
        dest_path += DATA_OUTPUT_FORMAT[options[:output_format]][:extension]
      end
      dest_path = SuperFile::new(dest_path) unless dest_path.instance_of?(SuperFile)
      dest_path.write code_final
    end
    # Retourner ce code dans tous les cas
    return code_final
  end
  alias :as_kramdown :kramdown


end
