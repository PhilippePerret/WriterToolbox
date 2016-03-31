# encoding: UTF-8
=begin

Extension String pour le traitement des documents Markdown

    >> "CITATION" AUTEUR - SOURCE

=end
class ::String

  # Traitements supplémentaires pour les document Markdown
  #
  # Fonctionnement :
  # La méthode découpe en paragraphe et parse chacun d'eux
  # en testant son amorce qui définit toujours une possibilité
  # de traitement.
  def extra_kramdown output_format = :html
    self.split("\n").collect do |line_init|
      line = line_init.strip
      case line
      when /^>>/ then line.kramdown_citations(output_format)
      else line_init
      end
    end.join("\n")
  end

  TEMPLATES_CITATIONS = {
    html: {
      avec_source: "<div class='quote'><span class='content'>%{citation}</span><span class='ref'><span class='auteur'>%{auteur}</span> - <span class='source'>%{source}</span></span></div>",
      sans_source: "<div class='quote'><span class='content'>%{citation}</span><span class='ref'><span class='auteur'>%{auteur}</span></span></div>"
    }
  }
  def kramdown_citations output_format = :html
    matched = self.match(/>> ?"(.+?)" ?(.*?)(?: - (.*))?$/).to_a
    debug "matched: #{matched.inspect}"
    citation  = matched[1]
    auteur    = matched[2]
    source    = matched[3]
    key = source.nil? ? :sans_source : :avec_source
    template = TEMPLATES_CITATIONS[output_format][key]
    template % {citation: citation, auteur: auteur, source: source}
  end

end
