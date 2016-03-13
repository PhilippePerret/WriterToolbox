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

    code = self.read

    # Si le format de sortie est de l'ERB, il faut protéger les
    # balises ERB sinon, kramdown transformerait les pourcentages en
    # signe pourcentage.
    if options[:output_format] == :erb
      code = code.gsub(/<\%/,'ERB-').gsub(/\%>/,'-ERB')
    end

    # Si une méthode formate_balises_propres existe, il
    # faut l'appeler sur le code pour les transformer
    code = code.formate_balises_propres if "".respond_to?(:formate_balises_propres)

    # Si une méthode de traitement des images existe,
    # il faut l'appeler
    code = formate_balises_images_in(code) if self.respond_to?(:formate_balises_images_in)

    #
    # = MAIN TRAITEMENT =
    #
    code_final = Kramdown::Document.new(code).send(mdown_method)

    if options[:output_format] == :erb
      code_final = code_final.gsub(/ERB-/,'<%').gsub(/-ERB/,'%>')
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
