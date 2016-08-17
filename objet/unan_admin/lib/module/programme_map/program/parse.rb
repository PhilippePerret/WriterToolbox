# encoding: UTF-8
class UNANProgramme

  # = main =
  #
  # Méthode principale qui parse le fichier programme.txt
  #
  def parse
    debug "-> parse"
    @fulldata = Hash.new
    c = Array.new


    # On crée une première ligne factice qui sera le programme
    # lui-même (pour ne pas avoir à traiter de conditions plus
    # bas sur l'existence ou non d'un élément parent)
    iline = LineProgramme.new(
      retrait: 0,
      raw_line: "JP 001-366 LE PROGRAMME UNAN"
    )
    iline.analyse
    niveau_retrait_courant  = 0
    element_courant         = iline

    raw_code.split("\n").each do |line|
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
        raw_line:   line
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
    error 'Un erreur est survenue (regarder le debug)'
  ensure
    debug "<- parse"
    return c.join("\n").in_pre
  end
  # /parse

end #/UNANProgramme
