# encoding: UTF-8
=begin

Extension de la classe SuperFile pour mettre en forme les documents
insérés dans un texte Markdown (mais ça peut être utilisé n'importe où).

Ces documents sont repérés par les balises :

document/

DOC/

/DOC

/document

NOTES
-----

  * Le traitement doit se faire avant le traitement Kramdown proprement
    dit car les retours chariots sont traités réellement dans un environnement
    de document.

=end

class MEFDocument

  # Le code entier
  attr_accessor :code

  # Le code en train d'être traité
  attr_accessor :codet

  # La légende éventuelle
  attr_accessor :legend

  # Le format de sortie (pour le moment, seul :html est traité)
  attr_accessor :output_format

  # {Array} Les classes CSS (styles) après la balise DOC/
  # Note : Elles ne contiennent pas "document"
  attr_accessor :classes

  def initialize code = nil, csss = []
    set_code(code) unless code.nil?
    @output_format = output_format || :html
    csss = csss.split(/[ \.]/) if csss.instance_of?(String)
    @classes = csss.unshift('document')
  end

  # Sortie retournée après traitement
  def output output_format = nil
    @output_format ||= output_format
    "\n#{traite_code}\n"
  end

  # Traitement du code, ligne après ligne.
  def traite_code
    @codet = code
    analyse_code
    @codet = case output_format
    when :html
      if events?
        @codet.traite_as_events_html
      elsif scenario?
        @codet.traite_as_script_html
      else
        lines.collect{ |l| l.traite_as_line_of_document_html }.join('')
      end.traite_as_document_content_html
    end
    # Le code entièrement traité
    self.in_section + self.legend
  end

  def in_section
    @grand_titre = (@grand_titre.nil? ? "" : @grand_titre.in_h1)
    (@grand_titre + @codet).in_section(class:classes.join(' ')).gsub(/\n/,'')
  end
  def legend
    return "" if @legend_content.nil? || @legend_content == ""
    @legend_content.in_div(class: 'document_legend')
  end

  # Première analyse du code, pour voir s'il a un grand titre
  # et une légende
  def analyse_code
    first_line = lines.first
    last_line = lines.last
    if first_line.start_with?('# ')
      @grand_titre = first_line[2..-1].strip
      lines.shift
    end
    if last_line.start_with?('/')
      @legend_content = last_line[1..-1].strip
      lines.pop
    end
    # On reconstitue le texte
    @codet = lines.join("\n")
    @lines = lines
  end

  def lines
    @lines ||= @codet.split("\n")
  end

  def scenario?
    @is_scenario ||= classes.include?('scenario')
  end
  def events?
    @is_events ||= classes.include?('events')
  end

  # Définition du code entier, on en profite pour
  # rationnaliser les retours à la ligne
  def set_code code
    @code = code.gsub(/\r\n?/,"\n").chomp.strip
  end

end

class ::String

  def mef_document output_format = :html
    return self unless self.match(/\nDOC\//)
    str = (self + "\n").gsub(/\nDOC\/(.*?)\n(.*?)\/DOC\n/m){
      classes_css = $1.freeze
      doc_content = $2.freeze
      MEFDocument::new(doc_content, classes_css).output(output_format)
    }
    return str
  end

  # Pour traiter le contenu avec une sortie HTML
  def traite_as_document_content_html
    str = self
    str = str.gsub(/\n/, "<br />")
    return str
  end

  # Traite le string comme le contenu d'un scénario
  def traite_as_script_html
    self.split("\n").collect do |line|
      css, line = case line
      when /^I:/ then
        ['intitule', line[2..-1].strip]
      when /^A:/
        ['action', line[2..-1].strip]
      when /^(N|P):/
        ['personnage', line[2..-1].strip]
      when /^J:/
        ['note_jeu', line[2..-1].strip]
      when /^D:/
        ['dialogue', line[2..-1].strip]
      when /\/(.*?)$/
        # Ne pas traiter la dernière ligne, qui peut être
        # une légende
        [nil, line]
      else
        [nil, line.traite_as_line_of_document_html]
      end
      line.traite_as_markdown_html.in_div(class:css) unless line.nil?
    end.join('')
  end
  # Traite le string comme une liste d'évènements d'évènemencier
  # Chaque ligne doit commencer par "- "
  def traite_as_events_html
    str = self.split("\n")
    str.collect do |line|
      if line.start_with?("- ")
        ("-".in_span(class:'t') + line[2..-1].traite_as_markdown_html).in_div(class:'e')
      else
        line.traite_as_line_of_document_html
      end
    end.join("")
  end

  # Traitement de toutes les lignes de texte, même celles traitées
  # en particulier (ligne d'évènemencier, de scénario, etc.)
  #
  # On retire les balises p qui ont été insérées par kramdown pour ne
  # garder que le texte corrigé. C'est la méthode appelante elle-même
  # qui doit insérer le code dans un container.
  def traite_as_markdown_html
    # self.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>').
    # gsub(/\*(.+?)\*/, '<em>\1</em>')
    res = Kramdown::Document.new(self.strip, {hard_wrap: false}).send(:to_html)
    res.strip.sub(/^<p>(.*?)<\/p>$/,'\1')
  end

  # Traitement d'une ligne comme la ligne d'un document quand elle
  # n'a pas pu être traitée autrement
  def traite_as_line_of_document_html
    case self
    when /^(\#+) /
      tout, dieses, titre = self.match(/^(\#+) (.*?)$/).to_a
      ht = "h#{dieses.length}"
      "<#{ht}>#{titre.traite_as_markdown_html}</#{ht}>"
    when /^(  |\t)/
      # Ligne débutant par une tabulation ou un double espace
      # => C'est un retrait, un texte qu'il faut mettre à la
      #    marge.
      # On regarde la longueur du retrait. Rappel : ce retrait
      # peut se faire soit avec deux espaces soit avec une
      # tabulation.
      retrait = self.match(/^((?:  |\t)+)/).to_a[1].gsub(/  /,"\t").length
      self.strip.traite_as_markdown_html.in_div(class:"p rtt#{retrait}")
    when ""
      "&nbsp;".in_div(class:'p')
    else
      self.traite_as_markdown_html.in_div(class:'p')
    end
  end

end
