# encoding: UTF-8
class UNANProgramme

  # = main =
  #
  # Méthode principale qui parse le fichier PROGRAMME_MAP.TXT
  #
  def parse
    @fulldata = Hash.new
    c = Array.new


    # On crée une première ligne factice qui sera le programme
    # lui-même (pour ne pas avoir à traiter de conditions plus
    # bas sur l'existence ou non d'un élément parent)
    iline = LineProgramme.new(
      retrait: 0,
      raw_line: "JP 001-366 LE PROGRAMME UNAN",
      index: 0
    )
    iline.analyse
    niveau_retrait_courant  = 0
    element_courant         = iline

    line_number = nil # pour le débug

    raw_code.split("\n").each_with_index do |line, index|

      line_number = index + 1

      line.strip != '' || next
      line.start_with?('#') && next

      c << "\n\n"
      c << "-"*60
      c << "Niveau retrait courant : #{niveau_retrait_courant}"
      c << "Élément courant : #{element_courant.nil? ? 'aucun' : element_courant.line}"
      c << "-"*60

      # On calcule le retrait pour connaitre l'imbrication
      retrait = nil
      line = line.sub(/^( *)/){ retrait = ($1 || '').length; ''}
      niveau_retrait = (retrait / 4) + 1

      # === Création de l'instance et analyse ===
      iline = LineProgramme.new(
        retrait:    niveau_retrait,
        raw_line:   line,
        index:      index + 1
      )
      iline.analyse
      # ==========================================

      c << "\nNOUVELLE LIGNE (R: #{niveau_retrait}): '#{iline.raw_line}' (type: #{iline.type})"

      if iline.retrait > niveau_retrait_courant
        c << "=> (retrait &gt;) Ajout de la ligne à : #{element_courant.line}"
        element_courant.add_item iline
      elsif iline.retrait < niveau_retrait_courant
        diff = niveau_retrait_courant - iline.retrait
        parent = element_courant.parent
        diff.times{ |itime| parent = parent.parent }
        c << "=> (retrait &lt;)  Ajout de la ligne à : #{parent.line}"
        parent.add_item iline
      else
        element_courant.parent.add_item iline
        c << "=> (retrait =)  Ajout de la ligne à : #{element_courant.parent.line}"
      end

      element_courant         = iline
      niveau_retrait_courant  = iline.retrait
    end
    # /fin de boucle sur chaque ligne

  rescue Exception => e
    debug e
    error "Un erreur est survenue avec la ligne #{line_number} (regarder le debug) : #{e.message}"
  ensure
    debug "<- parse"
    return c.join("\n").in_pre
  end
  # /parse

end #/UNANProgramme
