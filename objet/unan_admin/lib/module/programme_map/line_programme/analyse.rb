# encoding: UTF-8
class LineProgramme

  # = main =
  #
  # Méthode principale qui analyse la ligne et la transforme
  # Cette analyse permet de récupérer son type, ses références à des
  # travaux, etc.
  #
  def analyse
    @line = raw_line
    @line = analyse_as_segment      @line
    @line = analyse_as_todo         @line
    @line = analyse_as_travail      @line
    @line.strip
  end

  def type
    @type ||= begin
      case raw_line
      when /^#{REG_SEGMENT_PDAYS}/o then :segment
      when /^#{REG_PDAY}/o          then :segment
      when /^TODO:? /               then :todo
      when /#{REG_TRAVAIL} ?/o      then :travail
      else :description
      end
    end
  end

  # ---------------------------------------------------------------------
  #   Sous méthode d'analyse qui permetttent d'analyser la ligne en
  #   fonction de son contenu
  # ---------------------------------------------------------------------

  # Quand la ligne commence par un segment de jours-programme
  # Retourne la ligne traitée
  def analyse_as_segment l
    pday_deb, pday_fin = [nil, nil]
    l =
      case l
      when /^#{REG_SEGMENT_PDAYS}/o
        l.sub(/^#{REG_SEGMENT_PDAYS}/o){
          pday_deb  = $1.freeze
          pday_fin  = $2.freeze
          '' # on remplace par rien
        }
      when /^#{REG_PDAY}/o
        l.sub(/^#{REG_PDAY}/o){
          pday_deb  = $1.freeze
          '' # on remplace par rien
        }
      else
        l
      end
    @pday_deb = pday_deb
    @pday_fin = pday_fin
    return l
  end

  # Retourne la ligne traitée
  def analyse_as_todo l
    l.sub(/^TODO:? /,'')
  end

  # Retourne la ligne traitée
  def analyse_as_travail l
    l.gsub(/#{REG_TRAVAIL} ?/){ # l'espace avant REG_TRAVAIL est normale
      type_work = $1.freeze # p.e. WORK
      wid = $2.freeze
      if wid.nil?
        self.travaux << {id: nil, type: type_work}
      else
        wid = wid.strip.to_i.nil_if_zero # ID ou nil
        self.travaux << {id: wid, type: type_work}
      end
      # La liste des liens vers les travaux sera mis à la fin de la ligne, ou
      # en boutons, donc on efface l'emplacement
      ''
    }
  end

end #/LineProgramme
