# encoding: UTF-8
=begin
Nomenclature
  STRT   Structure
  PERS   Personnage
  DYNA   Dynamique
  THEM   Thématique
  DOCU   Documentation
  ANAF   Analyse de film

  WORK ID du travail absolu.
  PAGE ID de la page de cours propre au programme

  NOTE
    * Il suffit d'indiquer [WORK] ou [PAGE], etc. pour créer un lien qui
      va permettre de créer un work, etc. (sûr pour les works mais à voir
      pour les autres éléments)

=end
raise_unless_admin

class UNANProgramme
  include Singleton

  # = main =
  #
  # Méthode principale qui parse le fichier programme.txt
  #
  def parse
    @fulldata = Hash.new
    c = String.new

    niveau_retrait_courant = -1
    element_parent_courant = nil
    element_courant = nil

    raw_code.split("\n").each do |line|
      line.strip != '' || next
      retrait = nil
      line = line.sub(/^( *)/){ retrait = ($1 || '').length; ''}
      niveau_retrait = retrait / 4
      if line =~ /^#{REG_SEGMENT_PDAYS}/o
        pday_deb, pday_fin = nil, nil
        line.sub(/^#{REG_SEGMENT_PDAYS}/o){
          pday_deb  = $1.freeze
          pday_fin    = $2.freeze
          c << "De #{pday_deb} à #{pday_fin}"
          ''
        }
      end
      c << "L: '#{line}' (retrait : #{niveau_retrait})\n"

      iline = LineProgramme.new(
        retrait:  niveau_retrait,
        line:     line
      )
      if niveau_retrait == niveau_retrait_courant
        iline.parent = element_parent_courant
        element_parent_courant.items << iline
      elsif niveau_retrait < niveau_retrait_courant

      elsif niveau_retrait > niveau_retrait_courant
        element_parent_courant = iline
      end


      element_courant         = iline
      niveau_retrait_courant  = niveau_retrait
    end

    return c.in_pre
  end
  # /parse

  def raw_code
    @raw_code ||= (UnanAdmin.folder + 'programme.txt').read
  end
  # /raw_code

end
