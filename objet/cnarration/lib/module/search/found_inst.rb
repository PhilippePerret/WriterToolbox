# encoding: UTF-8
class Cnarration
class Search
class Found

  # {Cnarration::Search} La recherche contenant ce found
  attr_reader :search

  # Mis à TRUE si c'est un found dans un titre
  attr_accessor :in_titre

  # {Cnarration::Search::Grep} La recherche qui contient ce
  # found dans les textes
  # N'est défini QUE si c'est un found dans un texte
  # de fichier
  attr_accessor :igrep

  # {String} Texte brut tel que relevé par la commande
  # `grep`
  attr_reader :raw

  # {String} Path complet du fichier
  attr_reader :file_fullpath

  # {String} Texte complet de la ligne, contenant la
  # recherche.
  attr_accessor :text_line

  # {Fixnum} Numéro de ligne dans le fichier
  attr_reader :num_line
  # {Fixnum} Décalage dans le texte complet du fichier
  attr_reader :offset

  attr_accessor :page_titre

  # +search+      {Cnarration::Search} Instance de la recherche
  # +raw_found+   {String} Le texte brut de la recherche tel que remonté
  # par la commande `grep` si c'est une recherche dans le
  # texte ou le titre si c'est une recherche dans le titre
  def initialize isearch, raw_found
    @search   = isearch
    @raw      = raw_found
  end

  def parse
    raw_splited = raw.split(':')
    # debug "raw_splited : #{raw_splited.pretty_inspect}"
    @file_fullpath, num_line, offset = raw_splited[0..2]
    @num_line   = num_line.to_i
    @offset     = offset.to_i
    @text_line = raw_splited[3..-1].join(':').strip
    @in_texte  = true
  end

  # Sortie à afficher pour ce found
  #
  # Comme le fichier a peut-être déjà été traité, on peut envoyer
  # son identifiant pour accélérer les choses.
  def output in_texte
    @in_texte = in_texte
    debug "@in_texte est #{@in_texte.inspect}"
    c = "#{text_line_with_exergue}".in_span(class:'text')
    if in_texte == true
      # ERROR: C'EST INCOMPRÉHENSIBLE, MÊME LORSQUE C'EST UN
      # TITRE LE SPECS_FOUND EST ÉCRIT…………………………
      # DONC, POUR LE MOMENT, JE PRÉFÈRE SUPPRIMER CETTE LIGNE
      # c += specs_found
    end

    c.in_div(class:'found')
  end

  # Retourne le texte avec les mots mis en exergue
  def text_line_with_exergue
    @text_line_with_exergue ||= begin
      iterations = 0
      # TODO: Tenir compte de -i et -w
      formated = text_line.gsub(/(#{search.searched})/){
        iterations += 1
        "<span class='found'>#{$1}</span>"
      }
      @iterations = iterations
      debug "@in_texte est #{@in_texte.inspect}"
      (@in_texte ? "" : "TITRE : ") + formated
    end
  end

  # Nombre de fois où le mot apparait dans le texte
  # Pour le calculer, on formate le texte final
  def iterations
    @iterations || text_line_with_exergue
    @iterations
  end

  # Les spécificités du found (ligne, offset, etc.) lorsque c'est
  # un found dans un fichier.
  def specs_found
    "ligne : #{num_line} - décalage : #{offset}".in_div(class:'right tiny')
  end

  # Path relatif du fichier dans le dossier narration sans l'extension
  def file_handler
    @file_handler || dispatch_book_and_handler_from_path
    @file_handler
  end
  def livre_id
    @livre_id || dispatch_book_and_handler_from_path
    @livre_id
  end

  attr_writer :page_id
  def page_id
    @page_id ||= begin
      res = igrep.search.table_pages.select(where:"livre_id = #{livre_id} AND handler = '#{file_handler}'", colonnes:[:titre])
      self.page_titre = res.values.first[:titre]
      res.keys.first
    end
  end

  def in_titre? ; in_titre == true  end
  def in_texte? ; in_titre == nil   end

  # Méthode qui prend le path relatif pour en extraire
  # l'ID du livre et le handler du fichier qui permettront
  # de trouver son identifiant.
  # Produit :
  #   - @livre_id
  #   - @file_handler
  def dispatch_book_and_handler_from_path
    r = relative_path.split('/')
    book_folder   = r.shift
    @file_handler   = r.join('/')[0..-5]
    @livre_id       = Cnarration::SYM2ID[book_folder.to_sym]
  end


  def relative_path
    @relative_path ||= begin
      file_fullpath.sub(/^#{igrep.fullpath_cnarration_folder}\//,'')
    end
  end

end #/Found
end #/Search
end #/Cnarration
