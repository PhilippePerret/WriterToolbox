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
  # s'il ne peut en consulter que le tier.
  def consultable?
    return true if user.subscribed? || user.admin?
  end

end #/Page
end #/Cnarration
