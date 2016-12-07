# encoding: UTF-8
class Cnarration
class Page


  # Retourne TRUE si le fichier erb (semi-dynamique) est plus
  # vieux que le fichier markdown ou si le fichier contient
  # des fichiers inclus ou exemples plus vieux que le fichier
  # final semidyn.
  def out_of_date?
    return true if path_semidyn.older_than?( path )
    return out_of_date_per_inclusion?
  end
  # Retourne true si le fichier est out of date à cause d'un
  # ficheir inclus (par INCLUDE ou par EXEMPLE)
  def out_of_date_per_inclusion?
    code = path.read
    if code.match(/EXEMPLE\[/)
      dos_cours = String.folder_textes_exemples_in_cours
      dos_semid = String.folder_textes_exemples_in_semidyn
      code.scan(/EXEMPLE\[(.*?)\]/).to_a.each do |p|
        pcours = dos_cours + p
        psemid = dos_semid + p
        return true if pcours.exist? && path_semidyn.older_than?( pcours )
        return true if psemid.exist? && path_semidyn.older_than?( psemid )
      end
    end
    if code.match(/INCLUDE\[/)
      code.scan(/INCLUDE\[(.*?)\]/).to_a.each do |p|
        return true if path_semidyn.older_than?( SuperFile.new(p) )
      end
    end
    return false
  end

  # En fonction du type (bit 1 des options)
  def page?           ; type == 1 end
  def sous_chapitre?  ; type == 2 end
  def chapitre?       ; type == 3 end

  def only_enligne?
    @only_enligne ||= printed_version == 1
  end
  alias :online :only_enligne?

  def papier?
    @is_version_papier = printed_version == 0 if @is_version_papier === nil
    @is_version_papier
  end


end #/Page
end #/Cnarration
