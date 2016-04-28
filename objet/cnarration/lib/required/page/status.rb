# encoding: UTF-8
class Cnarration
class Page


  # Retourne TRUE si le fichier erb (semi-dynamique) est plus
  # vieux que le fichier markdown
  def out_of_date?
    path_semidyn.older_than? path
  end

  # En fonction du type (bit 1 des options)
  def page?           ; type == 1 end
  def sous_chapitre?  ; type == 2 end
  def chapitre?       ; type == 3 end

  # Retourne true si l'utilisateur courant peut
  # consulter la page en entier, retourne false
  # s'il ne peut en consulter que le tiers.
  # Les bots google peuvent consulter aussi les
  # pages.
  def consultable?
    return user.subscribed? || user.admin? || user.google?
  end

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
