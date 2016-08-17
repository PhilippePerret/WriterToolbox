# encoding: UTF-8
class LineProgramme

  # = main =
  #
  # Méthode principale qui analyse la ligne et la transforme
  # Cette analyse permet de récupérer son type, ses références à des
  # travaux, etc.
  #
  def analyse
    @line =
      case raw_line
      when /^#{REG_SEGMENT_PDAYS}/o then analyse_as_segment
      when /^TODO:? /               then analyse_as_todo
      when /#{REG_TRAVAIL}/         then analyse_as_travail
      else                               analyse_as_description
      end.strip
  end

  # ---------------------------------------------------------------------
  #   Sous méthode d'analyse qui permetttent d'analyser la ligne en
  #   fonction de son contenu
  # ---------------------------------------------------------------------

  # Quand la ligne commence par un segment de jours-programme
  # Retourne la ligne traitée
  def analyse_as_segment
    @type = :segment
    pday_deb, pday_fin = nil, nil
    @line =
      raw_line.sub(/^#{REG_SEGMENT_PDAYS}/o){
        pday_deb  = $1.freeze
        pday_fin  = $2.freeze
        '' # on remplace par rien
      }
    @pday_deb = pday_deb
    @pday_fin = pday_fin
    return @line
  end

  # Retourne la ligne traitée
  def analyse_as_todo
    @type = :todo
    raw_line.sub(/^TODO:? /,'')
  end

  # Retourne la ligne traitée
  def analyse_as_travail
    @type = :travail
    raw_line.gsub(/#{REG_TRAVAIL} ?/){ # l'espace avant REG_TRAVAIL est normale
      type_work = $1.freeze # p.e. WORK
      wid   = $2.strip.to_i.nil_if_zero # ID ou nil
      if wid.nil?
        # C'est pour un nouveau travail ou un nouvel exemple
        self.travaux << {id: nil, type: type_work}
      else
        # C'est un travail, un exemple, etc. existant
        self.travaux << {id: wid, type: type_work}
      end
      # La liste des liens vers les travaux sera mis à la fin de la ligne, ou
      # en boutons, donc on efface l'emplacement
      ''
    }
  end

  def analyse_as_description
    @type = :description
    raw_line
  end
end #/LineProgramme
